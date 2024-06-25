import ARKit
import SwiftUI

struct MainView: View {

    var body: some View {
        Group {
            if ARConfiguration.isSupported {
                RoomCreatorView()
            } else {
                UnsupportedARScreenView()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - UnsupportedARScreenView
struct UnsupportedARScreenView: View {

    private enum Constants {
        static let unsupportedARText = "Your device don't support AR :("
        static let contentPadding = CGFloat(20)
        static let cornerRadius = CGFloat(10)
        static let strokeWidth = CGFloat(3)
        static let buttonPadding = CGFloat(10)
        static let closeApplicationText = "Close application"
    }

    var body: some View {
        ZStack {
            Color.secondaryColor

            HStack {
                Spacer()

                VStack {
                    Text(Constants.unsupportedARText)
                        .foregroundStyle(Color.dark)

                    Divider()
                        .overlay {
                            Rectangle()
                                .fill(Color.accent)
                        }
                        .padding(.vertical, Constants.contentPadding)

                    Text(Constants.closeApplicationText)
                        .foregroundStyle(Color.dark)
                        .padding(Constants.buttonPadding)
                        .background(Color.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(Color.accent, lineWidth: Constants.strokeWidth)
                        }
                        .onTapGesture {
                            exit(0)
                        }
                }
                .padding(.vertical, Constants.contentPadding)

                Spacer()
            }
            .background(Color.mainColor)
            .clipShape(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.dark, lineWidth: Constants.strokeWidth)
            }
            .padding(Constants.contentPadding)
        }
    }
}

#Preview {
    MainView()
}
