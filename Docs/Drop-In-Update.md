New Drop-In Docs (Beta)
------------------------------------

# What's new
- All new UI and integration for Drop-In
- Fetch a customer's payment method without showing UI
- UI elements, art, helpers and localization are now accessible
- Added Apple Pay support
- Customizable appearance
- And more...

# Fetch last used payment method
Usually, you’ll want to check if your user already has existing payment methods using `BTDropInController:fetchDropInResultForAuthorization` to determine if you need to show the Drop-In payment picker. Note that the handler will only return a result when using a client token that was created with a `customer_id`. `BTDropInResult` makes it easy to get a description and icon of the payment method.

![Example payment method icon and description](saved-paypal-method.png "Example payment method icon and description")

```swift
    BTDropInController(fetchDropInResultForAuthorization: clientTokenOrTokenizeKey) { (result, error) in
        if (error != nil) {
            print("ERROR")
        } else {
            let selectedPaymentOptionType = result.selectedPaymentOptionType
            let selectedPaymentMethod = result.selectedPaymentMethod
            let selectedPaymentMethodIcon = result.selectedPaymentIcon
            let selectedPaymentMethodDescription = result.selectedPaymentDescription
        }
    }
```
# Show Drop-In
Present `BTDropInController` to collect the customer's payment information and receive the `nonce` to send to your server. If your customer selected Apple Pay as their preferred payment method then `result.selectedPaymentOptionType == .ApplePay` but the `result.selectedPaymentMethod` will be `nil`.

![Example no saved payment method](no-payment-methods.png "Example no saved payment method")

```swift
    self.dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: BTDropInRequest())
    { (result, error) in
        if (error != nil) {
            print("ERROR")
        } else if (result?.cancelled == true) {
            print("CANCELLED")
        } else {
            let selectedPaymentOptionType = result.selectedPaymentOptionType
            let selectedPaymentMethod = result.selectedPaymentMethod
            let selectedPaymentMethodIcon = result.selectedPaymentIcon
            let selectedPaymentMethodDescription = result.selectedPaymentDescription
        }
        self.dropIn!.dismissViewControllerAnimated(true, completion: nil)
    }!
    self.presentViewController(self.dropIn!, animated: true, completion: nil)
```

If there are saved payment methods they will appear:

![Example saved payment method](saved-payment-methods.png "Example saved payment method")

# Apple Pay + Drop-In
If you support Apple Pay, you'll often want to customize the experience or display it in the final step of your checkout flow. Use `BTApplePayClient` when appropriate to tokenize the customer's Apple Pay information.
```swift
    let paymentRequest = PKPaymentRequest()
    paymentRequest.paymentSummaryItems = [
        PKPaymentSummaryItem.init(label: "Socks", amount: NSDecimalNumber(string: "100"))
    ]
    paymentRequest.supportedNetworks = [
        PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkDiscover, PKPaymentNetworkAmex
    ]
    paymentRequest.merchantCapabilities = .Capability3DS
    paymentRequest.currencyCode = "USD"
    paymentRequest.countryCode = "US"
    paymentRequest.merchantIdentifier = "com.braintreepayments.sandbox.Braintree-Demo"
    
    let client = BTAPIClient(authorization: self.clientToken!)
    
    let applePayClient = BTApplePayClient(APIClient: client!)
    applePayClient.presentApplePayFromViewController(self, withPaymentRequest: paymentRequest, completion: { (applePayPaymentMethod, error) in
        if (applePayPaymentMethod != nil) {
            self.showPurchaseAlert(applePayPaymentMethod!.nonce)
        }
    })
```

# Customization
Use `BTKAppearance` to customize the appearance of Drop-In and other BraintreeUIKit classes.
```swift
BTKAppearance.sharedInstance().primaryTextColor = UIColor.greenColor()
```
