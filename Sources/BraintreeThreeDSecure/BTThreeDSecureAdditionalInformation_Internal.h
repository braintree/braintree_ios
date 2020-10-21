#if SWIFT_PACKAGE
#import "BTThreeDSecureAdditionalInformation.h"
#else
#import <BraintreeThreeDSecure/BTThreeDSecureAdditionalInformation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureAdditionalInformation ()

/**
 The additional information as parameters which can be used for API requests.
 @return An NSDictionary representing the additional information.
 */
- (NSDictionary *)asParameters;

@end

NS_ASSUME_NONNULL_END
