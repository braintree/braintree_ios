#import <PassKit/PassKit.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

#import "BTApplePayCardNonce.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for Apple Pay errors.
 */
extern NSString * const BTApplePayErrorDomain;

/**
 Error codes associated with Apple Pay.
 */
typedef NS_ENUM(NSInteger, BTApplePayErrorType) {
    /// Unknown error
    BTApplePayErrorTypeUnknown = 0,
    
    /// Apple Pay is disabled in the Braintree Control Panel
    BTApplePayErrorTypeUnsupported,
    
    /// Braintree SDK is integrated incorrectly
    BTApplePayErrorTypeIntegration,
};

/**
 Used to process Apple Pay payments
 */
@interface BTApplePayClient : NSObject

/**
 Creates an Apple Pay client.

 @param apiClient An API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Creates a `PKPaymentRequest` with values from your Braintree Apple Pay configuration.

 It populates the following values of `PKPaymentRequest`: `countryCode`, `currencyCode`, `merchantIdentifier`, `supportedNetworks`.

 @param completion A completion block that returns the payment request or an error. This block is invoked on the main thread.
*/
- (void)paymentRequest:(void (^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error))completion;

/**
 Tokenizes an Apple Pay payment.

 @param payment A `PKPayment` instance, typically obtained by presenting a `PKPaymentAuthorizationViewController`
 @param completionBlock A completion block that is invoked when tokenization has completed. If tokenization succeeds,
        `tokenizedApplePayPayment` will contain a nonce and `error` will be `nil`; if it fails,
        `tokenizedApplePayPayment` will be `nil` and `error` will describe the failure.
*/
- (void)tokenizeApplePayPayment:(PKPayment *)payment
                     completion:(void (^)(BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
