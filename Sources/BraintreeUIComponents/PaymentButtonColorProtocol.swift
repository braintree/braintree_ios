import SwiftUI

/// Protocol for payment button color and styling logic
protocol PaymentButtonColorProtocol {
    /// Logo image name for the button
    var logoImageName: String? { get }

    /// Background color of the button
    var backgroundColor: Color { get }

    /// Whether the button should have an outline
    var hasOutline: Bool { get }
}
