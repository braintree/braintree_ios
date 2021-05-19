import BraintreePayPal

/**
 Options for the PayPal Vault flow.
 */
@objc public class BTPayPalNativeVaultRequest: BTPayPalVaultRequest, BTPayPalNativeRequest {


    // MARK: - Public

    /**
     Initializes a PayPal Vault request.

     - Parameter payPalReturnURL: The return URL provided to the PayPal Native UI experience.
     Used as part of the authentication process to identify your application. This value should match the one set in the `Return URLs` section of your application's dashboard on your [PayPal developer account](https://developer.paypal.com).

     - Returns: A PayPal Vault request.
     */
    @objc public init(payPalReturnURL: String) {
        self.payPalReturnURL = payPalReturnURL
        self.hermesPath = "v1/paypal_hermes/setup_billing_agreement"
        super.init()
    }

    // MARK: - Internal

    let payPalReturnURL: String
    let hermesPath: String
}
