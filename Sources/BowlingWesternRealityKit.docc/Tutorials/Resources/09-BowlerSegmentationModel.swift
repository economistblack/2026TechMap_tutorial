import CoreImage
import Vision

struct BowlerSegmentationModel {
    func makePersonMask(from pixelBuffer: CVPixelBuffer) async throws -> CIImage? {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .balanced
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try handler.perform([request])

        guard let mask = request.results?.first?.pixelBuffer else {
            return nil
        }

        return CIImage(cvPixelBuffer: mask)
    }
}
