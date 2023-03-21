import Foundation
import CardinalMobile

/// Text box customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2TextBoxCustomization: BTThreeDSecureV2BaseCustomization {

    // MARK: - Public Properties

    /// Width (integer value) of the text box border.
    public var borderWidth: Int {
        get { _borderWidth }
        @objc(setBorderWidth:) set {
            _borderWidth = newValue
            (cardinalValue as? TextBoxCustomization)?.borderWidth = Int32(newValue)
        }
    }

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var borderColor: String? {
        get { _borderColor }
        @objc(setBorderColor:) set {
            _borderColor = newValue
            (cardinalValue as? TextBoxCustomization)?.borderColor = newValue
        }
    }

    /// Radius (integer value) for the text box corners.
    public var cornerRadius: Int {
        get { _cornerRadius }
        @objc(setCornerRadius:) set {
            _cornerRadius = newValue
            (cardinalValue as? TextBoxCustomization)?.cornerRadius = Int32(newValue)
        }
    }

    // MARK: - Private Properties

    /// Used as a holder for Obj-C interoperability
    private var _borderWidth: Int = 0

    /// Used as a holder for Obj-C interoperability
    private var _borderColor: String?

    /// Used as a holder for Obj-C interoperability
    private var _cornerRadius: Int = 0

    // MARK: - Initializer

    public override init() {
        super.init()
        cardinalValue = TextBoxCustomization()
    }
}
