#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

#import <PassKit/PassKit.h>

/**
 BTConfiguration category for ApplePay
 */
@interface BTConfiguration (ApplePay)

/**
 Indicates whether Apple Pay is enabled for your merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isApplePayEnabled;

/**
 The Apple Pay payment networks supported by your Braintree merchant account.
*/
@property (nonatomic, readonly, nullable) NSArray <PKPaymentNetwork> *applePaySupportedNetworks;

/**
 Indicates if the Apple Pay merchant enabled payment networks are supported on this device.
*/
@property (nonatomic, readonly, assign) BOOL canMakeApplePayPayments;

/**
 The country code for your Braintree merchant account.
*/
@property (nonatomic, readonly, nullable) NSString *applePayCountryCode;

/**
 The Apple Pay currency code supported by your Braintree merchant account.
*/
@property (nonatomic, readonly, nullable) NSString *applePayCurrencyCode;

/**
 The Apple Pay merchant identifier associated with your Braintree merchant account.
*/
@property (nonatomic, readonly, nullable) NSString *applePayMerchantIdentifier;

@end
