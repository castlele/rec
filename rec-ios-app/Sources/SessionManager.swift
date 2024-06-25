import ARKit

protocol SessionManager: ARSCNViewDelegate {
    var session: ARSession { get }

    func configure(forScene scene: ARSCNView)
}
