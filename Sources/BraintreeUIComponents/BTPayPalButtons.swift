import SwiftUI

/// PayPal branded checkout button. Available in the colors primary (PayPal blue), black, and white.
public struct PayPalButton: View {

    let type: BTPaymentButtonStyle
    let action: () -> Void
    var width: CGFloat?

    public init(type: BTPaymentButtonStyle, width: CGFloat? = nil, action: @escaping () -> Void) {
        self.type = type
        self.width = width
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if let logoImage = type.logoImage {
                    Image(logoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                }
            }
            .frame(minWidth: width ?? 300)
            .frame(height: 45)
            .background(type.backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        type.hasOutline ? .black : .clear,
                        lineWidth: type.hasOutline ? 1 : 0
                    )
            )
            .accessibilityLabel("PayPal checkout button")
            .accessibilityHint("PayPal checkout button")
        }
    }
}

struct ContentView: View {

    var body: some View {
        VStack(spacing: 16) {
            // Primary Button
            PayPalButton(type: .primaryPayPal, width: 300) {}

            // Black Button
            PayPalButton(type: .black, width: 250) {}

            // White Button
            PayPalButton(type: .white, width: 100) {}
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
