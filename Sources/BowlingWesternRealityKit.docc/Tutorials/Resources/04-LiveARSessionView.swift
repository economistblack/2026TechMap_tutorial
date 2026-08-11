import ARKit
import RealityKit
import SwiftUI

struct LiveARSessionView: UIViewRepresentable {
    @Binding var captureModel: LiveCaptureModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        captureModel.status = .scanningPlane
        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {}
}
