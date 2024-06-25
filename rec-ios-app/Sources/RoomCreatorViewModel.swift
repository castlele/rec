import ARKit
import iGeometry
import iShapeTriangulation

final class RoomCreatorViewModel: NSObject, ObservableObject, SessionManager {

    enum ScanningState {
        case normal
        case newCorner
        case cornerClarification
    }

    @Published var currentState = ScanningState.normal
    @Published var area: CGFloat = .zero
    @Published var vertices = [CGPoint]()

    let session = ARSession()
    
    var isShareAvailable: Bool {
        isPreviewAvailable && isAreaAvailable
    }

    var isRestartAvailable: Bool {
        !cornerNodes.isEmpty
    }

    var isAreaAvailable: Bool {
        cornerNodes.count >= 3
    }

    var isPreviewAvailable: Bool {
        isAreaAvailable
    }

    private weak var scene: ARSCNView?
    private var cornerNodes = [SCNNode]()
    private lazy var cornerMarkerNode = CornerMarkerNode()
    private var configuration: ARConfiguration {
        let conf = ARWorldTrackingConfiguration()

        conf.planeDetection = [.horizontal]

        return conf
    }

    // MARK: - Public Methods

    func onAppear() {
        UIApplication.shared.isIdleTimerDisabled = true
        session.run(configuration)
    }

    func onDisappear() {
        UIApplication.shared.isIdleTimerDisabled = false
        session.pause()
    }

    func addCorner() {
        currentState = .newCorner
        cornerMarkerNode.isHidden = false
    }

    func anchorCorner() {
        currentState = .cornerClarification
        cornerMarkerNode.anchor()
    }

    func adjustCorner(_ direction: Direction) {
        cornerMarkerNode.move(inDirection: direction.vector)
    }

    func reset() {
        cornerMarkerNode.isHidden = true
        cornerMarkerNode.reset()

        vertices = []
        cornerNodes = []
        area = .zero
    }

    func confirmCorner() {
        currentState = .normal
        let newCorner = CornerMarkerNode()

        newCorner.anchor()
        newCorner.simdWorldPosition = cornerMarkerNode.simdWorldPosition
        cornerNodes.append(newCorner)
        scene?.scene.rootNode.addChildNode(newCorner)

        func addLine() {
            guard cornerNodes.count >= 3 else { return }

            let triangulator = Triangulator()
            let points = cornerNodes.map { cornerNode in
                let pos = cornerNode.position
                let point = CGPoint(x: Double(pos.x), y: Double(pos.z))

                if !vertices.contains(point) {
                    vertices.append(point)
                }

                return Point(x: pos.x, y: pos.z)
            }
            if let triangles = try? triangulator.triangulateDelaunay(points: points) {
                var area = Float.zero

                for i in 0..<triangles.count / 3 {
                    let ai = points[triangles[3 * i]]
                    let bi = points[triangles[3 * i + 1]]
                    let ci = points[triangles[3 * i + 2]]

                    let lenAB = sqrt(powf(bi.x - ai.x, 2.0) + powf(bi.y - ai.y, 2.0))
                    let lenBC = sqrt(powf(ci.x - bi.x, 2.0) + powf(ci.y - bi.y, 2.0))
                    let lenAC = sqrt(powf(ci.x - ai.x, 2.0) + powf(ci.y - ai.y, 2.0))

                    let semiArea = (lenAB + lenBC + lenAC) / 2

                    area += sqrt(
                        semiArea * (semiArea - lenAB) * (semiArea - lenBC) * (semiArea - lenAC)
                    )
                }

                self.area = CGFloat(area)
            }
        }

        addLine()

        cornerMarkerNode.isHidden = true
        cornerMarkerNode.reset()
    }

    // MARK: - SessionManager

    func configure(forScene scene: ARSCNView) {
        scene.scene.rootNode.addChildNode(cornerMarkerNode)

        cornerMarkerNode.isHidden = true

        self.scene = scene
    }
}

// MARK: - ARSCNViewDelegate

extension RoomCreatorViewModel: ARSCNViewDelegate {
    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {
        DispatchQueue.main.async { [self] in
            guard let scene,
                  let camera = session.currentFrame?.camera,
                  case .normal = camera.trackingState,
                  let query = scene.getRaycastQuery(),
                  let raycastResult = scene.castRay(for: query).first else {
                return
            }

            cornerMarkerNode.update(with: raycastResult)
        }
    }
}
