import AVFoundation
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreVideo
import Foundation
import Vision

struct VideoProcessingError: Error, CustomStringConvertible {
    let description: String
}

func makePixelBufferPool(width: Int, height: Int) throws -> CVPixelBufferPool {
    let attrs: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
        kCVPixelBufferIOSurfacePropertiesKey as String: [:]
    ]

    var pool: CVPixelBufferPool?
    let status = CVPixelBufferPoolCreate(nil, nil, attrs as CFDictionary, &pool)
    guard status == kCVReturnSuccess, let pool else {
        throw VideoProcessingError(description: "Could not create pixel buffer pool")
    }
    return pool
}

func makeBuffer(from pool: CVPixelBufferPool) throws -> CVPixelBuffer {
    var buffer: CVPixelBuffer?
    let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    guard status == kCVReturnSuccess, let buffer else {
        throw VideoProcessingError(description: "Could not create output pixel buffer")
    }
    return buffer
}

func scaleToFill(_ image: CIImage, size: CGSize) -> CIImage {
    let extent = image.extent
    let scale = max(size.width / extent.width, size.height / extent.height)
    let scaled = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    let x = (scaled.extent.width - size.width) / 2
    let y = (scaled.extent.height - size.height) / 2
    return scaled.cropped(to: CGRect(x: x, y: y, width: size.width, height: size.height))
        .transformed(by: CGAffineTransform(translationX: -x, y: -y))
}

func makeWesternBackground(reference: CIImage, size: CGSize, context: CIContext) -> CIImage {
    let base = scaleToFill(reference, size: size)
    let colorControls = CIFilter.colorControls()
    colorControls.inputImage = base
    colorControls.saturation = 1.18
    colorControls.contrast = 1.08
    colorControls.brightness = 0.02

    let vignette = CIFilter.vignette()
    vignette.inputImage = colorControls.outputImage ?? base
    vignette.intensity = 0.7
    vignette.radius = 1.6

    return (vignette.outputImage ?? base).cropped(to: CGRect(origin: .zero, size: size))
}

func makePersonMask(for image: CIImage, size: CGSize) throws -> CIImage? {
    let request = VNGeneratePersonSegmentationRequest()
    request.qualityLevel = .accurate
    request.outputPixelFormat = kCVPixelFormatType_OneComponent8

    let handler = VNImageRequestHandler(ciImage: image, orientation: .up)
    try handler.perform([request])

    guard let maskBuffer = request.results?.first?.pixelBuffer else {
        return nil
    }

    let mask = CIImage(cvPixelBuffer: maskBuffer)
    return scaleToFill(mask, size: size)
        .applyingFilter("CIMorphologyMaximum", parameters: [kCIInputRadiusKey: 18.0])
        .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 3.5])
        .cropped(to: CGRect(origin: .zero, size: size))
}

func process(inputURL: URL, backgroundURL: URL, outputURL: URL) async throws {
    try? FileManager.default.removeItem(at: outputURL)

    let asset = AVURLAsset(url: inputURL)
    let tracks = try await asset.loadTracks(withMediaType: .video)
    guard let videoTrack = tracks.first else {
        throw VideoProcessingError(description: "No video track found")
    }

    let naturalSize = try await videoTrack.load(.naturalSize)
    let transform = try await videoTrack.load(.preferredTransform)
    let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)
    let fps = nominalFrameRate > 0 ? nominalFrameRate : 30
    let transformedSize = naturalSize.applying(transform)
    let width = Int(abs(transformedSize.width).rounded())
    let height = Int(abs(transformedSize.height).rounded())
    let outputSize = CGSize(width: width, height: height)
    print("Input size: \(width)x\(height), fps: \(fps)")

    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = outputSize
    videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(max(Int32(fps.rounded()), 1)))

    let transformedRect = CGRect(origin: .zero, size: naturalSize).applying(transform)
    let finalTransform = transform.concatenating(
        CGAffineTransform(translationX: -transformedRect.origin.x, y: -transformedRect.origin.y)
    )
    let instruction = AVMutableVideoCompositionInstruction()
    let duration = try await asset.load(.duration)
    instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
    layerInstruction.setTransform(finalTransform, at: .zero)
    instruction.layerInstructions = [layerInstruction]
    videoComposition.instructions = [instruction]

    let reader = try AVAssetReader(asset: asset)
    let readerOutput = AVAssetReaderVideoCompositionOutput(
        videoTracks: [videoTrack],
        videoSettings: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
    )
    readerOutput.videoComposition = videoComposition
    readerOutput.alwaysCopiesSampleData = false
    guard reader.canAdd(readerOutput) else {
        throw VideoProcessingError(description: "Cannot add reader output")
    }
    reader.add(readerOutput)

    let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    let writerInput = AVAssetWriterInput(
        mediaType: .video,
        outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 8_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
    )
    writerInput.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: writerInput,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
    )
    guard writer.canAdd(writerInput) else {
        throw VideoProcessingError(description: "Cannot add writer input")
    }
    writer.add(writerInput)

    let audioTracks = try await asset.loadTracks(withMediaType: .audio)
    var audioReaderOutput: AVAssetReaderTrackOutput?
    var audioWriterInput: AVAssetWriterInput?
    if let audioTrack = audioTracks.first {
        let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        if reader.canAdd(audioOutput) {
            reader.add(audioOutput)
            audioReaderOutput = audioOutput
        }

        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
        if writer.canAdd(audioInput) {
            writer.add(audioInput)
            audioWriterInput = audioInput
        }
    }

    let context = CIContext(options: [.workingColorSpace: NSNull()])
    guard let backgroundNSImage = NSImage(contentsOf: backgroundURL),
          let backgroundData = backgroundNSImage.tiffRepresentation,
          let backgroundBitmap = NSBitmapImageRep(data: backgroundData),
          let backgroundCI = CIImage(bitmapImageRep: backgroundBitmap) else {
        throw VideoProcessingError(description: "Could not load background image")
    }
    let westernBackground = makeWesternBackground(reference: backgroundCI, size: outputSize, context: context)
    let pool = try makePixelBufferPool(width: width, height: height)

    guard reader.startReading(), writer.startWriting() else {
        throw VideoProcessingError(description: "Could not start reader/writer")
    }
    writer.startSession(atSourceTime: .zero)

    var frameIndex = 0
    while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
        autoreleasepool {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            var cameraFrame = CIImage(cvPixelBuffer: imageBuffer)
            cameraFrame = scaleToFill(cameraFrame, size: outputSize)

            let mask = (try? makePersonMask(for: cameraFrame, size: outputSize))
            let outputImage: CIImage
            if let mask {
                let blend = CIFilter.blendWithMask()
                blend.inputImage = cameraFrame
                blend.backgroundImage = westernBackground
                blend.maskImage = mask
                outputImage = (blend.outputImage ?? cameraFrame).cropped(to: CGRect(origin: .zero, size: outputSize))
            } else {
                outputImage = cameraFrame
            }

            do {
                let outBuffer = try makeBuffer(from: pool)
                context.render(outputImage, to: outBuffer)
                while !writerInput.isReadyForMoreMediaData {
                    Thread.sleep(forTimeInterval: 0.002)
                }
                adaptor.append(outBuffer, withPresentationTime: presentationTime)
                frameIndex += 1
                if frameIndex % Int(max(fps, 1)) == 0 {
                    print("Processed \(frameIndex) frames")
                }
            } catch {
                print("Frame failed: \(error)")
            }
        }
    }
    writerInput.markAsFinished()

    if let audioReaderOutput, let audioWriterInput {
        while let audioSample = audioReaderOutput.copyNextSampleBuffer() {
            while !audioWriterInput.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.002)
            }
            audioWriterInput.append(audioSample)
        }
        audioWriterInput.markAsFinished()
    }

    await writer.finishWriting()
    if writer.status != .completed {
        throw writer.error ?? VideoProcessingError(description: "Writer failed")
    }
    print("Wrote \(outputURL.path)")
}

let args = CommandLine.arguments
guard args.count == 4 else {
    fputs("Usage: WesternBackgroundVideo <input.mp4> <background.png> <output.mp4>\n", stderr)
    exit(64)
}

do {
    try await process(
        inputURL: URL(fileURLWithPath: args[1]),
        backgroundURL: URL(fileURLWithPath: args[2]),
        outputURL: URL(fileURLWithPath: args[3])
    )
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
