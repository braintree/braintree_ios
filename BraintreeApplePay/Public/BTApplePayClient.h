#import <PassKit/PassKit.h>

#import "BTNullability.h"
#import "BTAPIClient.h"
#import "BTTokenizedApplePayPayment.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString * const BTApplePayErrorDomain;
typedef NS_ENUM(NSInteger, BTApplePayErrorType) {
    BTApplePayErrorTypeUnknown = 0,
    BTApplePayErrorTypeUnsupported,
};

@interface BTApplePayClient : NSObject

/// Creates an Apple Pay client.
///
/// @param apiClient An API client
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;


- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));


/// Tokenizes an Apple Pay payment.
///
/// @param payment A `PKPayment` instance, typically obtained by presenting a `PKPaymentAuthorizationViewController`
/// @param completionBlock A completion block that is invoked when tokenization has completed. If tokenization succeeds,
///        `tokenizedApplePayPayment` will contain a nonce and `error` will be `nil`; if it fails,
///        `tokenizedApplePayPayment` will be `nil` and `error` will describe the failure.
- (void)tokenizeApplePayPayment:(PKPayment *)payment
                     completion:(void (^)(BTTokenizedApplePayPayment * __BT_NULLABLE tokenizedApplePayPayment, NSError * __BT_NULLABLE error))completionBlock;

@end

BT_ASSUME_NONNULL_END
