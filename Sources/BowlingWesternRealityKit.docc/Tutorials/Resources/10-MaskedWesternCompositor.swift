import CoreImage

struct MaskedWesternCompositor {
    private let context = CIContext()

    func composite(
        cameraFrame: CIImage,
        westernBackground: CIImage,
        bowlerMask: CIImage
    ) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = cameraFrame
        filter.backgroundImage = westernBackground
        filter.maskImage = bowlerMask
        return filter.outputImage ?? cameraFrame
    }
}
