#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowDriver.h"

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
};

/**
 Category on BTPaymentFlowDriver for 3D Secure
 */
@interface BTPaymentFlowDriver (ThreeDSecure)

@end

NS_ASSUME_NONNULL_END
