import ARKit

final class CornerMarkerNode: SCNNode {

    private static let velocity = Float(0.01)

    private var isAnchored = false

    override init() {
        super.init()

//        let box = SCNBox(width: 0.05, height: 0.5, length: 0.05, chamferRadius: 0.0)
        let box = SCNBox(width: 0.01, height: 0.1, length: 0.01, chamferRadius: 0.0)

        self.geometry = box
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func update(with raycastResult: ARRaycastResult) {
        guard !isHidden, !isAnchored else { return }

        simdWorldPosition = raycastResult.worldTransform.translation
    }

    func move(inDirection dir: SIMD2<Float>) {
        simdPosition.x += Self.velocity * dir.x
        simdPosition.z += Self.velocity * dir.y
    }
    
    func reset() {
        isAnchored = false
    }

    func anchor() {
        isAnchored = true
    }
}
