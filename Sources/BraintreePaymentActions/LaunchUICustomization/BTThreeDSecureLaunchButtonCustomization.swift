import Foundation
import CardinalMobile

/// Button types that can be customized in 3D Secure 2 flows.
@objc public enum BTThreeDSecureLaunchButtonType: Int {

    /// Verify button
    case verify

    /// Continue button
    case `continue`

    /// Next button
    case next

    /// Cancel button
    case cancel

    /// Resend button
    case resend
}

/// Button customization options for 3D Secure 2 flows.
///
/// Deliberately duplicated from `BraintreeThreeDSecure`'s identical `BTThreeDSecureV2ButtonCustomization`
/// rather than shared, so this module's only dependency is the `CardinalMobile` binary — not the
/// existing `BraintreeThreeDSecure` module — keeping the Payment Actions drive path fully isolated from the
/// existing 3DS flow.
@objcMembers public class BTThreeDSecureLaunchButtonCustomization: BTThreeDSecureLaunchBaseCustomization {

    // MARK: - Public Properties

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var backgroundColor: String? {
        get { _backgroundColor }
        @objc(setBackgroundColor:) set {
            _backgroundColor = newValue
            (cardinalValue as? ButtonCustomization)?.backgroundColor = newValue
        }
    }

    /// Radius (integer value) for the button corners.
    public var cornerRadius: Int {
        get { _cornerRadius }
        @objc(setCornerRadius:) set {
            _cornerRadius = newValue
            (cardinalValue as? ButtonCustomization)?.cornerRadius = Int32(newValue)
        }
    }

    // MARK: - Private Properties

    /// Used as a holder for Obj-C interoperability
    private var _backgroundColor: String?

    /// Used as a holder for Obj-C interoperability
    private var _cornerRadius: Int = 0

    // MARK: - Initializer

    public override init() {
        super.init()
        cardinalValue = ButtonCustomization()
    }
}
