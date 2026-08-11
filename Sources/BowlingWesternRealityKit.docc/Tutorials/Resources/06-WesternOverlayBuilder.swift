import RealityKit
import simd

struct WesternOverlayBuilder {
    func makeScene(for lane: BowlingLaneAnchorDescription) -> Entity {
        let root = Entity()
        root.name = "Gentleman League Western Overlay"

        let laneHalfWidth = max(Float(lane.width) * 1.2, 0.85)
        let propOffset = laneHalfWidth + 0.35

        let sign = ModelEntity(
            mesh: .generateBox(size: [1.4, 0.12, 0.5]),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )
        sign.name = WesternOverlayAsset.saloonSign.rawValue
        sign.position = [0, 0.45, -2.2]

        let leftRail = makeRail(x: -laneHalfWidth)
        let rightRail = makeRail(x: laneHalfWidth)

        let leftCactus = makeCactusCluster(x: -propOffset, z: -0.85, height: 0.62)
        let rightCactus = makeCactusCluster(x: propOffset + 0.2, z: -1.95, height: 0.48)
        let saloonFront = makeWesternSetFacade(x: -propOffset - 0.28, z: -2.65, signText: WesternOverlayAsset.westernSetFacade.rawValue)
        let stableFront = makeWesternSetFacade(x: propOffset + 0.32, z: -2.85, signText: WesternOverlayAsset.westernTown.rawValue)
        let barrelStack = makeBarrelStack(x: propOffset, z: -0.65)
        let wagonWheel = makeWagonWheel(x: -propOffset - 0.18, z: -1.55)

        root.addChild(sign)
        root.addChild(leftRail)
        root.addChild(rightRail)
        root.addChild(leftCactus)
        root.addChild(rightCactus)
        root.addChild(saloonFront)
        root.addChild(stableFront)
        root.addChild(barrelStack)
        root.addChild(wagonWheel)
        return root
    }

    private func makeRail(x: Float) -> ModelEntity {
        let rail = ModelEntity(
            mesh: .generateBox(size: [0.08, 0.08, 3.6]),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )
        rail.position = [x, -0.12, -1.2]
        return rail
    }

    private func makeCactusCluster(x: Float, z: Float, height: Float) -> Entity {
        let cactus = Entity()
        cactus.name = WesternOverlayAsset.cactus.rawValue

        let material = SimpleMaterial(color: .green, isMetallic: false)
        let trunk = ModelEntity(mesh: .generateBox(size: [0.1, height, 0.1]), materials: [material])
        trunk.position = [0, height * 0.5 - 0.16, 0]

        let leftArm = ModelEntity(mesh: .generateBox(size: [0.08, height * 0.38, 0.08]), materials: [material])
        leftArm.position = [-0.11, height * 0.45 - 0.16, 0]
        leftArm.orientation = simd_quatf(angle: 0.35, axis: [0, 0, 1])

        let rightArm = ModelEntity(mesh: .generateBox(size: [0.08, height * 0.32, 0.08]), materials: [material])
        rightArm.position = [0.12, height * 0.58 - 0.16, 0]
        rightArm.orientation = simd_quatf(angle: -0.35, axis: [0, 0, 1])

        let sandPatch = ModelEntity(
            mesh: .generateBox(size: [0.46, 0.025, 0.34]),
            materials: [SimpleMaterial(color: .yellow, isMetallic: false)]
        )
        sandPatch.position = [0, -0.18, 0]

        cactus.addChild(sandPatch)
        cactus.addChild(trunk)
        cactus.addChild(leftArm)
        cactus.addChild(rightArm)
        cactus.position = [x, 0, z]
        return cactus
    }

    private func makeWesternSetFacade(x: Float, z: Float, signText: String) -> Entity {
        let facade = Entity()
        facade.name = signText

        let wood = SimpleMaterial(color: .brown, isMetallic: false)
        let wall = ModelEntity(mesh: .generateBox(size: [0.78, 0.52, 0.08]), materials: [wood])
        wall.position = [0, 0.08, 0]

        let roof = ModelEntity(mesh: .generateBox(size: [0.9, 0.1, 0.12]), materials: [wood])
        roof.position = [0, 0.39, 0]

        let doorway = ModelEntity(
            mesh: .generateBox(size: [0.2, 0.34, 0.09]),
            materials: [SimpleMaterial(color: .black, isMetallic: false)]
        )
        doorway.position = [0, -0.03, -0.01]

        let porch = ModelEntity(mesh: .generateBox(size: [0.92, 0.04, 0.28]), materials: [wood])
        porch.position = [0, -0.2, 0.14]

        facade.addChild(wall)
        facade.addChild(roof)
        facade.addChild(doorway)
        facade.addChild(porch)
        facade.position = [x, 0, z]
        return facade
    }

    private func makeBarrelStack(x: Float, z: Float) -> Entity {
        let barrels = Entity()
        barrels.name = WesternOverlayAsset.barrelStack.rawValue

        for index in 0..<3 {
            let barrel = ModelEntity(
                mesh: .generateBox(size: [0.18, 0.22, 0.18]),
                materials: [SimpleMaterial(color: .brown, isMetallic: false)]
            )
            let row = index == 2 ? 1 : 0
            barrel.position = [
                index == 1 ? 0.2 : 0,
                -0.13 + Float(row) * 0.2,
                index == 0 ? 0 : 0.1
            ]
            barrels.addChild(barrel)
        }

        barrels.position = [x, 0, z]
        return barrels
    }

    private func makeWagonWheel(x: Float, z: Float) -> Entity {
        let wheel = Entity()
        wheel.name = WesternOverlayAsset.wagonWheel.rawValue

        let material = SimpleMaterial(color: .brown, isMetallic: false)
        let hub = ModelEntity(mesh: .generateBox(size: [0.12, 0.12, 0.05]), materials: [material])
        let horizontalSpoke = ModelEntity(mesh: .generateBox(size: [0.44, 0.035, 0.04]), materials: [material])
        let verticalSpoke = ModelEntity(mesh: .generateBox(size: [0.035, 0.44, 0.04]), materials: [material])

        let rimTop = ModelEntity(mesh: .generateBox(size: [0.5, 0.035, 0.05]), materials: [material])
        rimTop.position = [0, 0.24, 0]

        let rimBottom = ModelEntity(mesh: .generateBox(size: [0.5, 0.035, 0.05]), materials: [material])
        rimBottom.position = [0, -0.24, 0]

        let rimLeft = ModelEntity(mesh: .generateBox(size: [0.035, 0.5, 0.05]), materials: [material])
        rimLeft.position = [-0.24, 0, 0]

        let rimRight = ModelEntity(mesh: .generateBox(size: [0.035, 0.5, 0.05]), materials: [material])
        rimRight.position = [0.24, 0, 0]

        wheel.addChild(rimTop)
        wheel.addChild(rimBottom)
        wheel.addChild(rimLeft)
        wheel.addChild(rimRight)
        wheel.addChild(horizontalSpoke)
        wheel.addChild(verticalSpoke)
        wheel.addChild(hub)
        wheel.position = [x, 0.02, z]
        wheel.orientation = simd_quatf(angle: -0.18, axis: [0, 1, 0])
        return wheel
    }
}
