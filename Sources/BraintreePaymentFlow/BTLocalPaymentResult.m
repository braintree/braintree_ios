#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTLocalPaymentResult.h>
#else
#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#endif

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

@implementation BTLocalPaymentResult

- (instancetype)initWithNonce:(NSString *)nonce
                         type:(NSString *)type
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataID:(NSString *)clientMetadataID
                      payerID:(NSString *)payerID
{
    if (self = [super init]) {
        _nonce = nonce;
        _type = type;
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _phone = phone;
        _billingAddress = [billingAddress copy];
        _shippingAddress = [shippingAddress copy];
        _clientMetadataID = clientMetadataID;
        _payerID = payerID;
    }
    return self;
}

@end
