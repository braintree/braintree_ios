import SwiftUI

/// Venmo payment button. Available in the colors primary (Venmo blue), black, and white.
public struct BTVenmoButton: View {

    /// The style of the Venmo payment button. Available in the colors primary (Venmo blue), black, and white. The Venmo logo image will automatically render the correct color version based off of the style passed in
    let style: BTVenmoButtonStyle

    /// The width of the Venmo payment button. Minimum width is 131 points. Maximum width is 300 points.
    let width: CGFloat?

    /// The Venmo payment button action.
    let action: () -> Void

    public init(style: BTVenmoButtonStyle, width: CGFloat? = nil, action: @escaping () -> Void) {
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
            .frame(height: 45)
            .background(style.backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(style.hasOutline ? Color.black : Color.clear, lineWidth: style.hasOutline ? 1 : 0)
            )
            .accessibilityLabel("Venmo checkout button")
            .accessibilityHint("Venmo checkout button")
        }
    }
}
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            BTVenmoButton(style: .black) {}
            BTVenmoButton(style: .blue) {}
            BTVenmoButton(style: .white) {}
        }
    }
}
