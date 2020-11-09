#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeApplePayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeApplePayVersionString[];

#import <PassKit/PassKit.h>

#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTApplePayClient.h>
#import <Braintree/BTConfiguration+ApplePay.h>
#import <Braintree/BTApplePayCardNonce.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeApplePay/BTApplePayClient.h>
#import <BraintreeApplePay/BTConfiguration+ApplePay.h>
#import <BraintreeApplePay/BTApplePayCardNonce.h>
#endif
