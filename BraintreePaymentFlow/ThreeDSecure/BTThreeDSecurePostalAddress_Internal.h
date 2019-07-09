#import "BTThreeDSecurePostalAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecurePostalAddress ()

/**
 The postal address as parameters which can be used for API requests.
 @return An NSDictionary representing the postal address.
 */
- (NSDictionary *)asParameters;

/**
 The postal address as parameters which can be used for API requests.
 The prefix value will be prepended to each key in the return dictionary
 @return An NSDictionary representing the postal address.
 */
- (NSDictionary<NSString *, NSString *> *)asParametersWithPrefix:(NSString *)prefix;

@end

NS_ASSUME_NONNULL_END
