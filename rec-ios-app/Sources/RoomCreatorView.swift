import SwiftUI
import PencilKit
import PDFKit

struct RoomCreatorView: View {

    @StateObject var viewModel = RoomCreatorViewModel()
    @State private var isPreviewPresented = false
    @State private var planUIImage: UIImage? = nil

    var body: some View {
        RECArView(sessionManager: viewModel)
            .onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
            .overlay(alignment: .bottom) {
                RoomScanningOverlay()
                    .environmentObject(viewModel)
            }
            .overlay(alignment: .top) {
                VStack {
                    HStack {
                        if viewModel.isAreaAvailable {
                            Text("Area: \(viewModel.area)m2")
                                .padding()
                                .background(Color.white)
                        }

                        Spacer()

                        if viewModel.isPreviewAvailable {
                            PreviewView(
                                vertices: $viewModel.vertices,
                                area: $viewModel.area,
                                uiImage: $planUIImage
                            )
                                .frame(width: 250, height: 250)
                                .cornerRadius(RECConstants.smallPadding)
                        }
                    }

                    HStack {
                        if viewModel.isShareAvailable {
                            RECButton(
                                tapAction: { isPreviewPresented.toggle() }
                            ) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }

                        Spacer()

                        if viewModel.isRestartAvailable {
                            RECButton(
                                tapAction: viewModel.reset
                            ) {
                                Image(systemName: "eraser")
                            }
                        }
                    }

                    Spacer()
                }
                .padding([.horizontal, .top], RECConstants.defaultPadding)
            }
            .environmentObject(viewModel)
            .sheet(isPresented: $isPreviewPresented) {
                PlanExportView(planUIImage: $planUIImage)
            }
    }
}

private struct PlanExportView: View {

    @Binding var planUIImage: UIImage?

    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @Environment(\.undoManager) private var undoManager

    var body: some View {
        VStack {
            HStack {
                RECButton(
                    tapAction: { undoManager?.undo() }
                ) {
                    Image(systemName: "arrow.uturn.backward")
                }

                RECButton(
                    tapAction: { undoManager?.redo() }
                ) {
                    Image(systemName: "arrow.uturn.forward")
                }

                RECButton(
                    tapAction: { canvasView.drawing = PKDrawing() }
                ) {
                    Image(systemName: "eraser")
                }

                Spacer()

                RECButton(
                    tapAction: {
                        guard let bottomImage = self.planUIImage else { return }

                        var drawing = self.canvasView.drawing.image(from: self.canvasView.bounds, scale: 0)

                        let newImage = autoreleasepool { () -> UIImage in
                            UIGraphicsBeginImageContextWithOptions(self.canvasView.frame.size, false, 0.0)
                            bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: self.canvasView.frame.size))
                            drawing.draw(in: CGRect(origin: CGPoint.zero, size: self.canvasView.frame.size))
                            let createdImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext() 
                            return createdImage!
                        }

                        let doc = PDFDocument()
                        
                        guard let page = PDFPage(image: newImage) else {
                            fatalError("")
                        }
                        
                        doc.insert(page, at: 0)

                        let data = doc.dataRepresentation()

                        let documentDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

                        let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")

                        do{
                            try data?.write(to: docURL)
                        }catch(let error){
                            print("error is \(error.localizedDescription)")
                        }
                    }
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .padding([.horizontal, .top], 16)

            Spacer()

            if let planUIImage {
                Image(uiImage: planUIImage)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        DrawingCanvas(
                            canvasView: $canvasView,
                            toolPicker: $toolPicker
                        )
                    }
            }

            Spacer(minLength: 30)
        }
    }
}

struct DrawingCanvas: UIViewRepresentable {

    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
    }
}

// MARK: - RoomScanningOverlay

private struct RoomScanningOverlay: View {

    private enum Constants {
        static let contentBottomPadding = CGFloat(20)
    }

    @EnvironmentObject var viewModel: RoomCreatorViewModel

    var body: some View {
        VStack(spacing: .zero) {
            Spacer()

            switch viewModel.currentState {
            case .normal:
                RECButton(
                    tapAction: viewModel.addCorner
                ) {
                    Image(systemName: "play")
                }

            case .newCorner:
                RECButton(
                    tapAction: viewModel.anchorCorner
                ) {
                    Image(systemName: "pause.fill")
                }

            case .cornerClarification:
                HStack {
                    RECButton(
                        tapAction: viewModel.confirmCorner
                    ) {
                        Image(systemName: "stop")
                    }
                    
                    Spacer()

                    DpadView(action: viewModel.adjustCorner(_:))
                }
                .padding(.horizontal, Constants.contentBottomPadding)
            }
        }
        .padding(.bottom, Constants.contentBottomPadding)
    }
}
