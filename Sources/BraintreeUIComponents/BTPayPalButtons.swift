import SwiftUI

/// PayPal payment button. Available in the colors primary (PayPal blue), black, and white.
public struct PayPalButton: View {

    /// The style of the PayPal payment button. Available in the colors primary (PayPal blue), black, and white.
    let style: BTPaymentButtonStyle
    
    /// The width of the PayPal payment button.
    var width: CGFloat?
    
    /// This is the width range for the PayPal payment button.
    private var widthRange: CGFloat {
        guard let width else { return 300 }
        return min(max(width, 131), 300)
    }
    
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
                    Image(logoImage, bundle: .uiComponents)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                }
            }
            .frame(width: widthRange)
            .frame(height: 45)
            .background(style.backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        style.hasOutline ? .black : .clear,
                        lineWidth: style.hasOutline ? 1 : 0
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
            PayPalButton(style: .primaryPayPal, width: 300) {}

            // Black Button
            PayPalButton(style: .black, width: 350) {}

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
