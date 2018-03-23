#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about the 3D Secure status of a payment method
 */
@interface BTThreeDSecureInfo : NSObject

/**
 Create a `BTThreeDSecureInfo` object from JSON.
 */
- (instancetype)initWithJSON:(BTJSON *)json;

/**
 If the 3D Secure liability shift has occurred
 */
@property (nonatomic, readonly, assign) BOOL liabilityShifted;

/**
 If the 3D Secure liability shift is possible
 */
@property (nonatomic, readonly, assign) BOOL liabilityShiftPossible;

/**
 If the 3D Secure lookup was performed
 */
@property (nonatomic, readonly, assign) BOOL wasVerified;

@end

NS_ASSUME_NONNULL_END
