#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 Category on BTConfiguration for ThreeDSecure
 */
@interface BTConfiguration (ThreeDSecure)

/**
 TODO
 */
@property (nonatomic, readonly, strong) NSString *cardinalAuthenticationJWT;

@end
