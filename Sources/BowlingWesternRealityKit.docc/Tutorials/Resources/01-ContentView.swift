import SwiftUI

struct ContentView: View {
    @State private var captureModel = LiveCaptureModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            LiveARSessionView(captureModel: $captureModel)
                .ignoresSafeArea()

            Button(captureModel.isRecording ? "촬영 정지" : "서부극 AR 촬영") {
                captureModel.toggleRecording()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
