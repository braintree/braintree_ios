import SwiftUI

/// Shared payment button view that works with any PaymentButtonColorProtocol
///  Not to be called directly. Use either BTPayPalButtons or BTVenmoButton instead.
struct PaymentButtonView<Color: PaymentButtonColorProtocol>: View {
    
    let color: Color
    let width: CGFloat?
    let logoHeight: CGFloat
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    /// This is the width range for the payment button.
    private var widthRange: CGFloat {
        guard let width else { return 300 }
        return min(max(width, 131), 300)
    }

    var body: some View {
        Button(action: action) {
            EmptyView()
        }
        .buttonStyle(PaymentButtonStyle(color: color, width: width, logoHeight: logoHeight))
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}
