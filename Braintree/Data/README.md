# Braintree Data - Advanced Fraud via Kount

## Overview

`Braintree/data` is our advanced fraud solution that is powered by `BTData` and Kount. This system enables you to collect device data and correlate it with a session identifier on your server.

By default, we suggest you utilize the default merchant credentials embedded in `[BTData defaultDataForEnvironment:delegate]`.

For direct Fraud Integration, please see [our documentation](https://www.braintreepayments.com/docs/general/fraud_tools#direct_fraud_tool_integration) or [contact our accounts team](accounts@braintreepayments.com).

**Note:** Use of `Braintree/data` and `BTData` is optional. Since `Braintree/data` contains references to Apple's IDFA, including it in your app may impact your App Store submission review process.

### Usage

First, add `pod "Braintree/data"` to your `Podfile`.

#### Default

Please follow these steps to integrate Braintree Data in your app:

1. Initialize `BTData` using the convenience constructor `defaultDataForEnvironment:delegate:` in your AppDelegate.
    * Be sure to pass the current Braintree environment, and remember to change this value before shipping to the app store.
    * The delegate is optional.

2. Retain your `BTData` instance for your entire application lifecycle.

3. Invoke `collect` (to generate a session id) or `collect:` (to provide a session id) as often as is needed. This will perform a device fingerprint and asynchronously send this data to Kount. This operation is relatively expensive. We recommend that you do this seldom and avoid interrupting your app startup with this call.


#### Direct Fraud Tool Integration

Direct fraud tool integration is similar to default. The only difference is upon initialization:

1. Initialize `BTData` using `initWithDebugOn:`.

2. Invoke `setCollectorUrl:` and `setKountMerchantId:` with the appropriate data.
    * Optionally, you may specify a delegate with `setDelegate:`.

3. Follow steps 2 and 3 above.

Please contact our account management team for more information.

### Server-Side Integration

When processing a user's purchase, pass the session id (returned by `collect` or passed into `collect:`) along with the other transaction details to your server. 

On your *server* include the session id in your request to Braintree.

For example in Ruby:

```ruby
result = Braintree::Transaction.sale(
  :amount => "100.00",
  :credit_card => {
    :number => params["credit_card_number"],
    :expiration_date => params["credit_card_expiration_date"],
    :cvv => params["credit_card_cvv"]
  },
  :device_session_id => params["BRAINTREE_DATA_SESSION_ID"]
)
```
