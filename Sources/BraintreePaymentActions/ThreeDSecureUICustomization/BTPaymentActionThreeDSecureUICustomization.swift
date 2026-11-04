import Foundation
import CardinalMobile

/// UI customization options for 3D Secure 2 flows.
@objcMembers public class BTPaymentActionThreeDSecureUICustomization: NSObject {

    // MARK: - Public Properties

    /// Toolbar customization options for 3D Secure 2 flows.
    public var toolbarCustomization: BTPaymentActionThreeDSecureToolbarCustomization? {
        didSet {
            let toolbarCustomization = toolbarCustomization?.cardinalValue as? ToolbarCustomization
            cardinalValue.setToolbar(toolbarCustomization)
        }
    }

    /// Label customization options for 3D Secure 2 flows.
    public var labelCustomization: BTPaymentActionThreeDSecureLabelCustomization? {
        didSet {
            let labelCustomization = labelCustomization?.cardinalValue as? LabelCustomization
            cardinalValue.setLabel(labelCustomization)
        }
    }

    /// Text box customization options for 3D Secure 2 flows.
    public var textBoxCustomization: BTPaymentActionThreeDSecureTextBoxCustomization? {
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
        _ buttonCustomization: BTPaymentActionThreeDSecureButtonCustomization,
        buttonType: BTPaymentActionThreeDSecureButtonType
    ) {
        let buttonCustomization = buttonCustomization.cardinalValue as? ButtonCustomization
        cardinalValue.setButton(buttonCustomization, buttonType: buttonType.cardinalValue)
    }
}

extension BTPaymentActionThreeDSecureButtonType {

    /// Maps by name to Cardinal's `ButtonType`.
    var cardinalValue: ButtonType {
        switch self {
        case .verify:
            return ButtonTypeVerify
        case .continue:
            return ButtonTypeContinue
        case .next:
            return ButtonTypeNext
        case .cancel:
            return ButtonTypeCancel
        case .resend:
            return ButtonTypeResend
        @unknown default:
            return ButtonTypeVerify
        }
    }
}
