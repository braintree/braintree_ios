#import "BTThreeDSecureResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureResult ()

/**
 The error message when the 3D Secure flow is unsuccessful. Available to merchants on BTThreeDSecureInfo.
 */
@property (nonatomic, copy) NSString *errorMessage;

/**
True if the 3D Secure flow was successful.
*/
@property (nonatomic, assign) BOOL success;

@end

NS_ASSUME_NONNULL_END
