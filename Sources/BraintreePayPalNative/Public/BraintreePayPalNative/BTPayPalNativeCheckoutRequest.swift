import BraintreePayPal

/**
 Options for the PayPal Checkout and PayPal Checkout with Vault flows.
 */
@objc public class BTPayPalNativeCheckoutRequest: BTPayPalCheckoutRequest, BTPayPalNativeRequest {

    // MARK: - Public

    /**
     Initializes a PayPal Checkout request.

     - Parameter payPalReturnURL: The return URL provided to the PayPal Native UI experience, which is used to identify your application. This value should match the one set in the `Return URLs` section of your application's dashboard on your [PayPal developer account](https://developer.paypal.com).

     - Parameter amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.

     - Returns: A PayPal Checkout request.
     */
    @objc public init(payPalReturnURL: String, amount: String) {
        self.payPalReturnURL = payPalReturnURL
        self.hermesPath = "v1/paypal_hermes/create_payment_resource"
        super.init(amount: amount)
    }

    // MARK: - Internal

    let payPalReturnURL: String
    let hermesPath: String
}
