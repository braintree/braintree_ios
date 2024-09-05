import Foundation
import CardinalMobile

/// Button types that can be customized in 3D Secure 2 flows.
@objc public enum BTThreeDSecureV2ButtonType: Int {

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

/// UI customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2UICustomization: NSObject {

    // MARK: - Public Properties

    /// Toolbar customization options for 3D Secure 2 flows.
    public var toolbarCustomization: BTThreeDSecureV2ToolbarCustomization? {
        didSet {
            let toolbarCustomization = toolbarCustomization?.cardinalValue as? ToolbarCustomization
            cardinalValue.setToolbar(toolbarCustomization)
        }
    }

    /// Label customization options for 3D Secure 2 flows.
    public var labelCustomization: BTThreeDSecureV2LabelCustomization? {
        didSet {
            let labelCustomization = labelCustomization?.cardinalValue as? LabelCustomization
            cardinalValue.setLabel(labelCustomization)
        }
    }

    /// Text box customization options for 3D Secure 2 flows.
    public var textBoxCustomization: BTThreeDSecureV2TextBoxCustomization? {
        didSet {
            let textBoxCustomization = textBoxCustomization?.cardinalValue as? TextBoxCustomization
            cardinalValue.setTextBox(textBoxCustomization)
        }
    }

    // MARK: - Internal Properties

    let cardinalValue = UiCustomization()

    // MARK: - Public Methods

    /// Set button customization options for 3D Secure 2 flows.
    /// - Parameters:
    ///   - buttonCustomization: Button customization options
    ///   - buttonType: Button type
    @objc(setButtonCustomization:buttonType:)
    public func setButton(_ buttonCustomization: BTThreeDSecureV2ButtonCustomization, buttonType: BTThreeDSecureV2ButtonType) {
        let buttonCustomization = buttonCustomization.cardinalValue as? ButtonCustomization
        let buttonType = ButtonType(UInt32(buttonType.rawValue))
        cardinalValue.setButton(buttonCustomization, buttonType: buttonType)
    }
}
