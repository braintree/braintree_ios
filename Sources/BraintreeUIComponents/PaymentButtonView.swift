import SwiftUI

/// Shared payment button view that works with any PaymentButtonColorProtocol
///  Not to be called directly. Use either BTPayPalButtons or BTVenmoButton instead.
struct PaymentButtonView<Color: PaymentButtonColorProtocol>: View {
    
    let color: Color
    let width: CGFloat?
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    @State private var isPressed = false

    /// This is the width range for the payment button.
    private var widthRange: CGFloat {
        guard let width else { return 300 }
        return min(max(width, 131), 300)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let logoImageName = color.logoImageName {
                    Image(logoImageName, bundle: .uiComponents)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 14)
                }
            }
            .frame(width: widthRange)
        }
        .frame(height: 45)
        .background(isPressed ? color.tappedButtonColor : color.backgroundColor)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    color.hasOutline ? .black : .clear,
                    lineWidth: color.hasOutline ? 1 : 0
                )
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}
