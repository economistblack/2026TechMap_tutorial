import Foundation
import RealityKit

/// A namespace for sample types used in the DocC tutorials.
public enum BowlingWesternRealityKit {
    /// The base catalog name used for DocC static hosting.
    public static let catalogName = "BowlingWesternRealityKit"
}

/// A simple description of a detected bowling lane in the live AR camera view.
public struct BowlingLaneAnchorDescription: Sendable {
    public let centerX: Double
    public let centerY: Double
    public let width: Double
    public let vanishingPointY: Double

    public init(centerX: Double, centerY: Double, width: Double, vanishingPointY: Double) {
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.vanishingPointY = vanishingPointY
    }
}

/// Western-themed background assets that can replace the bowling alley behind the bowler.
public enum WesternOverlayAsset: String, CaseIterable, Sendable {
    case saloonSign
    case woodenRails
    case cactus
    case westernSetFacade
    case barrelStack
    case wagonWheel
    case dustTrail
    case sheriffBadge
    case sunsetBackdrop
    case westernTown
}

/// Runtime states for the live AR capture experience.
public enum LiveCaptureState: Sendable {
    case idle
    case scanningPlane
    case segmentingBowler
    case detectingLane
    case backgroundReady
    case recording
    case saved
}
