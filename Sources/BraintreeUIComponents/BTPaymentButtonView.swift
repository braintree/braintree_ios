import SwiftUI

/// Shared payment button view that works with any PaymentButtonStyleProtocol
///  Not to be called directly. Use either BTPayPalButtons or BTVenmoButton instead.
struct PaymentButtonView<Style: PaymentButtonStyleProtocol>: View {
    
    let style: Style
    let width: CGFloat?
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let logoImage = style.logoImage {
                    Image(logoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                }
            }
            .frame(minWidth: style.minimumWidth, maxWidth: width ?? 300)
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
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
        }
    }
}
