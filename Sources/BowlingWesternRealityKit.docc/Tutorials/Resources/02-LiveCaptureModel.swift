import Foundation

struct LiveCaptureModel {
    var status: LiveCaptureState = .idle
    var savedVideoURL: URL?

    var isRecording: Bool {
        if case .recording = status { return true }
        return false
    }

    mutating func toggleRecording() {
        status = isRecording ? .backgroundReady : .recording
    }
}
