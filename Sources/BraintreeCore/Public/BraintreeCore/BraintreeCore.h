#import <UIKit/UIKit.h>
#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>

/// Project version number for BraintreeCore.
FOUNDATION_EXPORT double BraintreeCoreVersionNumber;

/// Project version string for BraintreeCore.
FOUNDATION_EXPORT const unsigned char BraintreeCoreVersionString[];

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/Braintree.h>
#else
#import <BraintreeCore/Braintree.h>
#endif
