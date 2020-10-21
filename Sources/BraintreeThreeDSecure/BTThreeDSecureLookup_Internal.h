#if SWIFT_PACKAGE
#import "BTThreeDSecureLookup.h"
#else
#import <BraintreeThreeDSecure/BTThreeDSecureLookup.h>
#endif

@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureLookup ()

- (instancetype)initWithJSON:(BTJSON *)JSON;

@end

NS_ASSUME_NONNULL_END
