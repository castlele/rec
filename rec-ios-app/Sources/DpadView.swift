import SwiftUI

enum Direction: String {
    case up, down
    case left, right

    var vector: SIMD2<Float> {
        switch self {
        case .up: [1, 0]
        case .down: [-1, 0]
        case .left: [0, 1]
        case .right: [0, -1]
        }
    }
}

struct DpadView: View {

    private enum Constants {
        static let buttonPadding = CGFloat(20)
        static let dpadPadding = buttonPadding / 1.2
        static let dpadSize = CGSize(width: buttonPadding * 7, height: buttonPadding * 7)
    }

    let action: (Direction) -> Void

    var body: some View {
        HStack(spacing: .zero) {
            VStack(spacing: .zero) {
                Spacer()
                button(direction: .left)
                Spacer()
            }

            VStack(spacing: .zero) {
                button(direction: .up)
                Spacer()
                button(direction: .down)
            }

            VStack(spacing: .zero) {
                Spacer()
                button(direction: .right)
                Spacer()
            }
        }
        .frame(size: Constants.dpadSize)
        .padding(Constants.dpadPadding)
        .background(Color.mainColor)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }

    private func button(direction: Direction) -> some View {
        RECButton(tapAction: {
            action(direction)
        }) {
            getImage(forDirection: direction)
        }
    }

    private func getImage(forDirection dir: Direction) -> Image {
        Image(systemName: "chevron.\(dir.rawValue)")
    }
}

#Preview {
    DpadView(action: { dir in print(dir.rawValue)})
}
