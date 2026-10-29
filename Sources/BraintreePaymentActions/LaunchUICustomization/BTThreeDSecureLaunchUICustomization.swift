import Foundation
import CardinalMobile

/// UI customization options for 3D Secure 2 flows.
///
/// Deliberately duplicated from `BraintreeThreeDSecure`'s identical `BTThreeDSecureV2UICustomization`
/// rather than shared, so this module's only dependency is the `CardinalMobile` binary — not the
/// existing `BraintreeThreeDSecure` module — keeping the Payment Actions drive path fully isolated from the
/// existing 3DS flow.
@objcMembers public class BTThreeDSecureLaunchUICustomization: NSObject {

    // MARK: - Public Properties

    /// Toolbar customization options for 3D Secure 2 flows.
    public var toolbarCustomization: BTThreeDSecureLaunchToolbarCustomization? {
        didSet {
            let toolbarCustomization = toolbarCustomization?.cardinalValue as? ToolbarCustomization
            cardinalValue.setToolbar(toolbarCustomization)
        }
    }

    /// Label customization options for 3D Secure 2 flows.
    public var labelCustomization: BTThreeDSecureLaunchLabelCustomization? {
        didSet {
            let labelCustomization = labelCustomization?.cardinalValue as? LabelCustomization
            cardinalValue.setLabel(labelCustomization)
        }
    }

    /// Text box customization options for 3D Secure 2 flows.
    public var textBoxCustomization: BTThreeDSecureLaunchTextBoxCustomization? {
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
    public func setButton(
        _ buttonCustomization: BTThreeDSecureLaunchButtonCustomization,
        buttonType: BTThreeDSecureLaunchButtonType
    ) {
        let buttonCustomization = buttonCustomization.cardinalValue as? ButtonCustomization
        let buttonType = ButtonType(UInt32(buttonType.rawValue))
        cardinalValue.setButton(buttonCustomization, buttonType: buttonType)
    }
}
