#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTPaymentFlowDriver.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowDriver.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for 3D Secure flow errors.
 */
extern NSString * const BTThreeDSecureFlowErrorDomain;

/**
 Error codes associated with 3D Secure flow.
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureFlowErrorType) {
    /// Unknown error
    BTThreeDSecureFlowErrorTypeUnknown = 0,
    
    /// 3D Secure failed during the backend card lookup phase; please retry
    BTThreeDSecureFlowErrorTypeFailedLookup,
    
    /// 3D Secure failed during the user-facing authentication phase; please retry
    BTThreeDSecureFlowErrorTypeFailedAuthentication,

    /// 3D Secure was not configured correctly
    BTThreeDSecureFlowErrorTypeConfiguration,
};

/**
 Category on BTPaymentFlowDriver for 3D Secure
 */
@interface BTPaymentFlowDriver (ThreeDSecure)

/**
 Creates a stringified JSON object containing the information necessary to perform a lookup.

 @param request The BTThreeDSecureRequest object where prepareLookup was called.
 @param completionBlock This completion will be invoked exactly once with the client payload string or an error.
 */
- (void)prepareLookup:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(NSString * _Nullable lookupPayload, NSError * _Nullable error))completionBlock;

/**
 Initialize a challenge from a server side lookup call.

 @param lookupResponse The json string returned by the server side lookup.
 @param request The BTThreeDSecureRequest object where prepareLookup was called.
 @param completionBlock This completion will be invoked exactly once when the payment flow is complete or an error occurs.
 */
- (void)initializeChallengeWithLookupResponse:(NSString *)lookupResponse request:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
