# Braintree / 3D Secure

This optional subspec of the Braintree v.zero SDK for iOS implements a native 3D Secure experience, which enables you authenticate customers using a login screen provided by the cardholder's issuing bank. By participating in 3D Secure, merchants can benefit from a liability shift and interchange savings.

3D Secure is only compatible with credit cards and must be performed immediately before each transaction in order to obtain the benefits of the liability shift.

3D Secure is popular in Europe, and it is also known as _Verified by Visa_ and _MasterCard Secure Code_.  For more information, visit our [developers site](https://developers.braintreepayments.com/ios/guides/3d-secure). 
To enroll in 3D Secure, please contact our support team at support@braintreepayments.com.


## Technical Details

You must integrate Braintree v.zero in order to use this implementation of 3D Secure. If you haven't done so already, get started with v.zero by following the [`Hello, Client!`](https://developers.braintreepayments.com/ios/start/hello-client) tutorial on our developers site.

To get started with our 3D Secure integration, add the following to your `Podfile`:

```ruby
pod "Braintree"
pod "Braintree/3D-Secure"
```

You must be using Braintree iOS version 3.6.0 or later to use 3D Secure.

Braintree's 3D Secure implementation must be initialized with a credit card and results in a payment method nonce. The input may come in the form of raw credit card details, a `BTCardPaymentMethod` or an payment method nonce. There are a number of ways to obtain a payment method, such as `-[Braintree tokenizeCard:completion:]`, `-[Braintree dropInViewControllerWithDelegate:]`, as well as server-side methods that generate a payment method nonce from a vault token.

To kick-off the 3D Secure flow, utilize `BTThreeDSecure`, which offers a high-level API around the so-called "lookup" and "authentication" steps: 

1. Import the 3D Secure code with `#import <Braintree/Braintree-3D-Secure.h>`
2. Initialize *and retain* an instance of `BTThreeDSecure`
3. Call one of the `verify…` methods, it is the caller's responsibility to retain the instance of `BTThreeDSecure`
4. Your delegate may receive a request to present a view controller, which you must present modally
5. Upon completion, your delegate will receive either an error or a new card payment method, which contains a single-use payment method nonce
  * Send this value to your server and create a transaction
  * This transaction will have the appropriate 3D Secure status associated with it
  * When 3D Secure fails, it is at the merchant's discretion to determine whether or not to continue with transaction creation without 3D Secure
  * The server-side client libraries offer an additional mechanism for enforcing 3D Secure server-side

## User Experience

User-facing authentication is only necessary in certain cases. This is determined primarily by the card network and the issuer's enrollment status. When authentication is required, the cardholder will see a web-based login form provided by the issuing bank. In other cases, the 3D Secure flow will complete without any user interaction.

Please keep in the following tips in mind when designing your mobile 3D Secure experience:

* To determine whether authentication is needed, the lookup step must be performed at each checkout
* The payment method and transaction amount must be defined before performing 3D Secure
* The `verify…` methods require network traffic and may take up to several seconds, as communication with the banks takes place on the backend
* Your app is responsible for displaying a loading indication while "lookup" is taking place
* When you receive a view controller from the SDK, you must present it modally, and it must not be modified
* Upon completion of the 3D Secure flow, you must still account for the asynchronous transaction creation, which takes place on the merchant's server
* Although it is possible to use 3D Secure with credit cards in the vault, the user-facing 3D Secure flow must occur *for each transaction*—the 3D Secure result cannot be saved in the vault

## See also

* Header docs in [`BTThreeDSecure.h`](./Public/BTThreeDSecure.h)
* Our [online documentation](https://developers.braintreepayments.com/ios/guides/3d-secure)
* General overview of the [3D Secure protocol](https://en.wikipedia.org/wiki/3-D_Secure)
