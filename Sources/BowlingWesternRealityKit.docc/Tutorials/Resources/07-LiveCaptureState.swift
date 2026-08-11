import Foundation

struct LiveCaptureState {
    enum Status {
        case idle
        case scanningPlane
        case segmentingBowler
        case detectingLane
        case backgroundReady
        case recording
        case saved(URL)
    }

    var status: Status = .idle
}
