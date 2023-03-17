import Foundation

/// Button customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2ButtonCustomization: BTThreeDSecureV2BaseCustomization {

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var backgroundColor: String? {
        didSet {
            ButtonCustomization().backgroundColor = backgroundColor
        }
    }

    /// Radius (integer value) for the button corners.
    public var cornerRadius: Int? {
        didSet {
            ButtonCustomization().cornerRadius = Int32(cornerRadius ?? 0)
        }
    }
}
