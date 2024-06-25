import ARKit
import SwiftUI

struct RECArView: UIViewRepresentable {

    let sessionManager: SessionManager

    private let view = ARSCNView()

    func makeUIView(context: Context) -> ARSCNView {
        sessionManager.configure(forScene: view)

        view.session = sessionManager.session
        view.delegate = sessionManager

#if DEBUG
        view.showsStatistics = true
        view.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
#endif

        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
}
