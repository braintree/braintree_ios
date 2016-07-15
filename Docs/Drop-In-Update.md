Drop-In Update (Beta)
------------------------------------

# What's new
- All new UI and integration for Drop-In
- Fetch a customer's payment method without showing UI
- UI elements, art, helpers and localization are now accessible
- Added Apple Pay and UnionPay support to Drop-In
- Customizable appearance
- And more...

Please create an [issue](https://github.braintreeps.com/braintree/braintree-ios/issues) with any comments or concerns

**Note** `BraintreeDropIn` requires iOS 9.X+

# Get the new Drop-In
To get the new Drop-In, add the following to your Podfile:
```
pod 'Braintree/DropIn'
```

# Fetch last used payment method
If your user already has an existing payment method, you may not need to show the Drop-In payment picker. You can check if they have an existing payment method using `BTDropInController:fetchDropInResultForAuthorization`. Note that the handler will only return a result when using a client token that was created with a `customer_id`. `BTDropInResult` makes it easy to get a description and icon of the payment method.

![Example payment method icon and description](saved-paypal-method.png "Example payment method icon and description")

```swift
    BTDropInController.fetchDropInResultForAuthorization(clientTokenOrTokenizationKey, handler: { (result, error) in
        if (error != nil) {
            print("ERROR")
        } else {
            // Use the BTDropInResult properties to update your UI
            let selectedPaymentOptionType = result!.paymentOptionType
            let selectedPaymentMethod = result!.paymentMethod
            let selectedPaymentMethodIcon = result!.paymentIcon
            let selectedPaymentMethodDescription = result!.paymentDescription
        }
    })
```
# Show Drop-In
Present `BTDropInController` to collect the customer's payment information and receive the `nonce` to send to your server.

![Example no saved payment method](no-payment-methods.png "Example no saved payment method")

```swift
    let request =  BTDropInRequest()
    request.displayCardTypes = [BTUIKPaymentOptionType.Visa.rawValue, BTUIKPaymentOptionType.MasterCard.rawValue]
    self.dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
    { (result, error) in
        if (error != nil) {
            print("ERROR")
        } else if (result?.cancelled == true) {
            print("CANCELLED")
        } else {
            // Use the BTDropInResult properties to update your UI
            let selectedPaymentOptionType = result!.paymentOptionType
            let selectedPaymentMethod = result!.paymentMethod
            let selectedPaymentMethodIcon = result!.paymentIcon
            let selectedPaymentMethodDescription = result!.paymentDescription
        }
        self.dropIn!.dismissViewControllerAnimated(true, completion: nil)
        }!
    self.presentViewController(self.dropIn!, animated: true, completion: nil)
```

If there are saved payment methods they will appear:

![Example saved payment method](saved-payment-methods.png "Example saved payment method")

# Apple Pay + Drop-In
Make sure the following is included in your Podfile:
```
pod 'Braintree/Apple-Pay'
```

Apple Pay can now be displayed as an option in Drop-In by setting the `showApplePayPaymentOption` to `true` on the `BTDropInRequest` object passed to Drop-In. Usually you'll want to make sure that the device can make a payment when setting `showApplePayPaymentOption`.

```swift
    let request =  BTDropInRequest()
    request.showApplePayPaymentOption = PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks([PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex])
```

**Important** If your customer selected Apple Pay as their preferred payment method then `result.paymentOptionType == .ApplePay` and the `result.paymentMethod` will be `nil`. Selecting Apple Pay does not display the Apple Pay sheet or create a nonce - you will still need to do that at the appropriate time in your app. Use `BTApplePayClient` to tokenize the customer's Apple Pay information - (view our official docs for more information)[https://developers.braintreepayments.com/guides/apple-pay/client-side/ios/v4].

# Customization
Use `BTUIKAppearance` to customize the appearance of Drop-In and other BraintreeUIKit classes.
```swift
// Example
BTUIKAppearance.sharedInstance().primaryTextColor = UIColor.greenColor()
```

Here is the full list of properties...
```swift
@property (nonatomic, strong) UIColor *overlayColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *barBackgroundColor;
@property (nonatomic, strong) NSString *fontFamily;
@property (nonatomic, strong) UIColor *sheetBackgroundColor;
@property (nonatomic, strong) UIColor *formFieldBackgroundColor;
@property (nonatomic, strong) UIColor *primaryTextColor;
@property (nonatomic, strong) UIColor *secondaryTextColor;
@property (nonatomic, strong) UIColor *disabledColor;
@property (nonatomic, strong) UIColor *placeholderTextColor;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *errorBackgroundColor;
@property (nonatomic, strong) UIColor *errorForegroundColor;
@property (nonatomic) UIBlurEffectStyle blurStyle;
@property (nonatomic) BOOL useBlurs;
```

# BraintreeUIKit

`BraintreeUIKit` is our new framework that makes our UI classes public and usable by anyone to create very specific checkout experience. This includes `localization`, `vector art`, `form fields` and other utils you might need when working with payments. `BraintreeUIKit` has no dependencies on other Braintree frameworks.

To get the standalone `BraintreeUIKit` framework, add the following to your Podfile:
```
pod 'Braintree/UIKit'
```

```swift
    // Example: Get a Visa card icon
    let visaIcon = BTUIKPaymentOptionCardView()
    visaIcon.paymentOptionType = BTUIKPaymentOptionTypeVisa;

    // Example: Create a generic form field and prepare it for autolayout
    let favoriteColorFormField = BTUIKFormField()
    favoriteColorFormField.translatesAutoresizingMaskIntoConstraints = false
    favoriteColorFormField.textField.placeholder = "Favorite Color"
    // ... add the form field to your view and use auto layout to position it
```

Take a look at `BTCardFormViewController.m` to see examples of using the form fields and their delegates.
