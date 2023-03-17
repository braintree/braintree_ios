import Foundation

/// Toolbar customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2ToolbarCustomization: BTThreeDSecureV2BaseCustomization {

    // MARK: - Public Properties

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var backgroundColor: String? {
        get { _backgroundColor }
        set { ToolbarCustomization().backgroundColor = newValue }
    }

    /// Text for the header.
    public var headerText: String? {
        get { _headerText }
        set { ToolbarCustomization().headerText = newValue }
    }

    /// Text for the button. For example, “Cancel”.
    public var buttonText: String? {
        get { _buttonText }
        set { ToolbarCustomization().buttonText = newValue }
    }

    // MARK: - Internal Properties

    /// Used as a holder for Obj-C interoperability
    var _backgroundColor: String?

    /// Used as a holder for Obj-C interoperability
    var _headerText: String?

    /// Used as a holder for Obj-C interoperability
    var _buttonText: String?
}
