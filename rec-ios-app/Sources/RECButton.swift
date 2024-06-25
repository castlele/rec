import SwiftUI

struct RECButton<Content: View>: View {

    let tapAction: () -> Void
    let content:() -> Content

    @State private var isHovered = false

    var body: some View {
        content()
            .foregroundStyle(Color.dark)
            .padding(Constants.buttonPadding)
            .background(Color.secondaryColor)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .fill(isHovered ? Color.dark.opacity(0.3) : .clear)
            }
            .overlay {
                Circle()
                    .stroke(
                        Color.accent,
                        style: .init(lineWidth: Constants.buttonStrokeWidth)
                    )
            }
            .onTapGesture {
                tapAction()
            }
            .hoverEffect(.highlight)
    }

    private func toggleHovering(isHovered: Bool? = nil) {
        withAnimation {
            if let isHovered {
                self.isHovered = isHovered
            } else {
                self.isHovered.toggle()
            }
        }
    }
}

#Preview {
    RECButton(tapAction: {}) {
        Text("Hello")
    }
}

// MARK: - Constants

private enum Constants {
    static let buttonPadding = CGFloat(20)
    static let buttonStrokeWidth = CGFloat(3)
}

