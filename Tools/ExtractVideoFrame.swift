import AVFoundation
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count == 3 || args.count == 4 else {
    fputs("Usage: ExtractVideoFrame <input.mp4> <output.png> [seconds]\n", stderr)
    exit(64)
}

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])
let asset = AVURLAsset(url: inputURL)
let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.maximumSize = CGSize(width: 900, height: 900)
let seconds = args.count == 4 ? (Double(args[3]) ?? 1.0) : 1.0

do {
    let image = try generator.copyCGImage(at: CMTime(seconds: seconds, preferredTimescale: 600), actualTime: nil)
    let rep = NSBitmapImageRep(cgImage: image)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ExtractVideoFrame", code: 1)
    }
    try data.write(to: outputURL)
    print(outputURL.path)
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
