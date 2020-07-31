#import "BTThreeDSecureResultNew.h"
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureResultNew ()

- (instancetype)initWithJSON:(BTJSON *)JSON;

@end

NS_ASSUME_NONNULL_END
