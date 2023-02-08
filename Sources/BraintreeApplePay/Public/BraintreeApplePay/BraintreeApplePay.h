#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeApplePayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeApplePayVersionString[];

#import <PassKit/PassKit.h>

#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BTApplePayClient.h>
#else
#import <BraintreeApplePay/BTApplePayClient.h>
#endif
