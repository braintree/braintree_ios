import Foundation

/// Toolbar customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2ToolbarCustomization: BTThreeDSecureV2BaseCustomization {

    // MARK: - Public Properties

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var backgroundColor: String? {
        get { _backgroundColor }
        @objc(setBackgroundColor:) set {
            _backgroundColor = newValue
            (cardinalValue as? ToolbarCustomization)?.backgroundColor = newValue
        }
    }

    /// Text for the header.
    public var headerText: String? {
        get { _headerText }
        @objc(setHeaderText:) set {
            _headerText = newValue
            (cardinalValue as? ToolbarCustomization)?.headerText = newValue
        }
    }

    /// Text for the button. For example, “Cancel”.
    public var buttonText: String? {
        get { _buttonText }
        @objc(setButtonText:) set {
            _buttonText = newValue
            (cardinalValue as? ToolbarCustomization)?.buttonText = newValue
        }
    }

    // MARK: - Internal Properties

    /// Used as a holder for Obj-C interoperability
    var _backgroundColor: String?

    /// Used as a holder for Obj-C interoperability
    var _headerText: String?

    /// Used as a holder for Obj-C interoperability
    var _buttonText: String?

    // MARK: - Initializer

    public override init() {
        super.init()
        cardinalValue = ToolbarCustomization()
    }
}
