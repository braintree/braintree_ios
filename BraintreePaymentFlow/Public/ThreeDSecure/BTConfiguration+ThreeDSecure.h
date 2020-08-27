#import <BraintreeCore/BTConfiguration.h>

/**
 Category on BTConfiguration for ThreeDSecure
 */
@interface BTConfiguration (ThreeDSecure)

/**
 JWT for use with initializaing Cardinal 3DS framework
 */
@property (nonatomic, readonly, strong) NSString *cardinalAuthenticationJWT;

@end
