import SwiftUI

/// PayPal payment button. Available in the colors primary (PayPal blue), black, and white.
public struct PayPalButton: View {

    /// The style of the PayPal payment button. Available in the colors primary (PayPal blue), black, and white.
    var color: BTPayPalButtonColor = .primary
    
    /// The width of the PayPal payment button.
    var width: CGFloat?
    
    /// This is the width range for the PayPal payment button.
    private var widthRange: CGFloat {
        guard let width else { return 300 }
        return min(max(width, 131), 300)
    }
    
    /// The PayPal payment button action.
    let action: () -> Void
    
    /// Creates a PayPal payment button.
    /// - Parameters:
    ///   - color: Button color
    ///   - width: Optional. Button width (min 131px, max 300px)
    ///   - action: Button action
    public init(color: BTPayPalButtonColor, width: CGFloat? = nil, action: @escaping () -> Void) {
        self.color = color
        self.width = width
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if let logoImage = color.logoImage {
                    Image(logoImage, bundle: .uiComponents)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                }
            }
            .frame(width: widthRange)
        }
        .frame(height: 45)
        .background(color.backgroundColor)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    color.hasOutline ? .black : .clear,
                    lineWidth: color.hasOutline ? 1 : 0
                )
        )
        .accessibilityLabel("PayPal checkout button")
        .accessibilityHint("PayPal checkout button")
    }
    
    struct ContentView: View {
        
        var body: some View {
            VStack(spacing: 16) {
                // Primary Button
                PayPalButton(color: .primary, width: 300) {}
                
                // Black Button
                PayPalButton(color: .black, width: 350) {}
                
                // White Button
                PayPalButton(color: .white, width: 100) {}
            }
        }
    }

    struct ContentView_Previews: PreviewProvider {

        static var previews: some View {
            ContentView()
        }
    }
}
