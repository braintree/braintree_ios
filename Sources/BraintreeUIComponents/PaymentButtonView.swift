import SwiftUI

/// Shared payment button view that works with any PaymentButtonColorProtocol
///  Not to be called directly. Use either BTPayPalButtons or BTVenmoButton instead.
struct PaymentButtonView<Color: PaymentButtonColorProtocol>: View {
    
    let color: Color
    let width: CGFloat?
    let logoHeight: CGFloat
    let accessibilityLabel: String
    let accessibilityHint: String
    let spinnerImageName: String?
    let isLoading: Bool
    let spinnerRotation: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            EmptyView()
        }
        .buttonStyle(
            PaymentButtonStyle(
                color: color,
                width: width,
                logoHeight: logoHeight,
                spinnerImageName: spinnerImageName,
                isLoading: isLoading,
                spinnerRotation: spinnerRotation
            )
        )
        .disabled(isLoading)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}
