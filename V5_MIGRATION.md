# Braintree iOS v5 (Beta) Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v4 to v5.

_Documentation for v5 will be published to https://developers.braintreepayments.com once it is available for general release._

## Supported versions

v5 supports a minimum deployment target of iOS 12+. It requires the use of Xcode 12+ and Swift 5+. If your application contains Objective-C code, the `Enable Modules` build setting must be set to `YES`.

## Swift Package Manager

v5 introduces support for Swift Package Manager. See the [README](/README.md#swift-package-manager-v5-beta) for more details.

## 3D Secure

In v4, 3D Secure classes were housed in the `BraintreePaymentFlow` module. In v5, `BraintreeThreeDSecure` is a standalone module offering the same 3DS functionality. The `BraintreePaymentFlow` module still houses Local Payment functionality.

#### Integration

<details><summary>CocoaPods</summary>
<p>

In your Podfile, add:
```
pod `Braintree/ThreeDSecure`
```

</p>
</details>

<details><summary>Carthage</summary>
<p>

You will need to add the `BraintreeThreeDSecure` framework to your project. See the Carthage docs for [integration instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

*Note:* In v5, using the `--no-use-binaries` flag with `carthage update` may result in a timeout.

*Note:* Long term support for Carthage is not guaranteed. Please update to SPM, if possible. Open a GitHub issue if there are concerns.

</p>
</details>

<details><summary>Swift Package Manager</summary>
<p>

Using the `BraintreeThreeDSecure` library with Swift Package Manager requires you to include the CardinalMobile framework. [See README](/README.md#swift-package-manager-v5-beta).

</p>
</details>

#### BTThreeDSecureRequestDelegate

The signature for the `BTThreeDSecureRequestDelegate` method `onLookupComplete` has changed:

```swift
public func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult result: BTThreeDSecureResult, next: @escaping () -> Void) {

}
```
The lookup information, such as `requiresUserAuthentication`, can be found on the result's `lookup` property:

```swift
result.lookup?.requiresUserAuthentication
```

#### 3DS2 UI Customization

On `BTThreeDSecureRequest`, the `uiCustomization` property was replaced with `v2UICustomization` of type `BTThreeDSecureV2UICustomization`. For 3DS2 UI customization, use the following new classes:

* `BTThreeDSecureV2UICustomization`
* `BTThreeDSecureV2ButtonCustomization`
* `BTThreeDSecureV2LabelCustomization`
* `BTThreeDSecureV2TextBoxCustomization`
* `BTThreeDSecureV2ToolbarCustomization`

## Apple Pay

For CocoaPods integrations, the Braintree Apple Pay subspec has been renamed from `Braintree/Apple-Pay` to `Braintree/ApplePay`.

## PayPal

Implementing the `BTViewControllerPresentingDelegate` is no longer required.

Registering a custom URL scheme in your Xcode project is also no longer required. 

Code previously used to set your return URL scheme can be deleted. **Note:** This only applies to the PayPal flow. Other payment methods (ex: Venmo, Local Payment Methods, 3DS) still require a custom URL scheme.
```
BTAppSwitch.setReturnURLScheme("com.your-company.your-app.payments")
```

## App Switch

v5 removes the `options` and `sourceApplication` params on methods in `BTAppSwitch`. 

If you're using `UISceneDelegate`, you don't need to make any code changes. 

If you aren't using `UISceneDelegate`, you will need to update the `handleOpenURL` method you call from within the `application:OpenURL:options` app delegate method.

```
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme?.localizedCaseInsensitiveCompare("com.your-company.your-app.payments") == .orderedSame {
        return BTAppSwitch.handleOpen(url)
    }
    return false
}
```
