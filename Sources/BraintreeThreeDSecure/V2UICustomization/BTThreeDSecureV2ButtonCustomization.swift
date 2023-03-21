import Foundation
import CardinalMobile

/// Button customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2ButtonCustomization: BTThreeDSecureV2BaseCustomization {

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
