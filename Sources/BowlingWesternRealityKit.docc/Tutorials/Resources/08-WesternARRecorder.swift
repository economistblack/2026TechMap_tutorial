import ReplayKit

final class WesternARRecorder {
    private let recorder = RPScreenRecorder.shared()

    func startRecording() async throws {
        try await recorder.startRecording()
    }

    func stopRecording() async throws -> RPPreviewViewController {
        try await recorder.stopRecording()
    }
}
