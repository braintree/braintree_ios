import SwiftUI

public struct PayPalButtonStyle: ButtonStyle {

    let backgroundColor: Color
    let tappedColor: Color

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 45)
            .background(configuration.isPressed ? tappedColor : backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
    }
}

/// PayPal branded checkout button. Available in the colors primary (PayPal blue), black, and white.
public struct PayPalButton: View {

    /// The style of the PayPal payment button. Available in the colors primary (PayPal blue), black, and white.
    let style: BTPaymentButtonStyle

    /// The width of the PayPal payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The PayPal payment button action.
    let action: () -> Void

    public init(style: BTPaymentButtonStyle, width: CGFloat? = nil, action: @escaping () -> Void) {
        self.style = style
        self.width = width
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if let logoImage = style.logoImage {
                    Image(logoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                }
            }
            .frame(minWidth: 131, maxWidth: width ?? 300)
        }
        .buttonStyle(PayPalButtonStyle(backgroundColor: style.backgroundColor, tappedColor: style.tappedButtonColor))
        .accessibilityLabel("PayPal checkout button")
        .accessibilityHint("PayPal checkout button")
    }
}

struct ContentView: View {

    var body: some View {
        VStack(spacing: 16) {
            // Primary Button
            PayPalButton(style: .primaryPayPal, width: 300) {}

            // Black Button
            PayPalButton(style: .black, width: 250) {}

            // White Button
            PayPalButton(style: .white, width: 100) {}
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
