import SwiftUI

/// Generic button style for payment buttons that handles interaction states
struct PaymentButtonStyle<Color: PaymentButtonColorProtocol>: ButtonStyle {
    
    let color: Color
    let width: CGFloat?
    let logoHeight: CGFloat
    
    /// This is the width range for the payment button.
    private var widthRange: CGFloat {
        guard let width else { return 300 }
        return min(max(width, 131), 300)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if let logoImageName = color.logoImageName {
                Image(logoImageName, bundle: .uiComponents)
                    .resizable()
                    .scaledToFit()
                    .frame(height: logoHeight)
            }
        }
        .frame(width: widthRange)
        .frame(height: 45)
        .background(configuration.isPressed ? color.tappedButtonColor : color.backgroundColor)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    color.hasOutline ? .black : .clear,
                    lineWidth: color.hasOutline ? 1 : 0
                )
        )
    }
}
