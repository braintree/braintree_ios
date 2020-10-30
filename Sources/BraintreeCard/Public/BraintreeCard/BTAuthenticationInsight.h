#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Information pertaining to the regulatory environment for a credit card if authentication insight
 is requested during tokenization.
 */
@interface BTAuthenticationInsight : NSObject

/**
 The regulation environment for the associated nonce to help determine the need
 for 3D Secure. See https://developers.braintreepayments.com/guides/3d-secure/advanced-options/ios/v4#authentication-insight
 for a list of possible values.
 */
@property (nonatomic, nullable, copy) NSString *regulationEnvironment;

@end

NS_ASSUME_NONNULL_END
