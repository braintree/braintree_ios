#import <Foundation/Foundation.h>

@interface BTThreeDSecureInfo : NSObject

///  Indicates that the payment method was eligible for 3D Secure
///
///  If `liabilityShiftPossible == YES` and `liabilityShifted == NO`,
///  then the user failed 3D Secure authentication.
///
///  @since 3.8.1
@property (nonatomic, readonly, assign) BOOL liabilityShiftPossible;

///  Indicates that the 3D Secure process worked and authentication was successful
///
///  If YES, the liability for fraud has been shifted to the bank.
///  NOTE: As a client-side value, this should not be trusted by your server.
///        If you want to ensure that a nonce passed 3D Secure authentication,
///        set the `required` option to `true` in your server integration.
///
///  @since 3.8.1
@property (nonatomic, readonly, assign) BOOL liabilityShifted;

+ (BTThreeDSecureInfo *)infoWithLiabilityShiftPossible:(BOOL)liabilityShiftPossible liabilityShifted:(BOOL)liabilityShifted;

@end
