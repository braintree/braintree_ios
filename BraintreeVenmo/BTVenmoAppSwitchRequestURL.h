#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTVenmoAppSwitchRequestURL : NSObject

/// The base app switch URL for Venmo
/// Does not include specific parameters
+ (NSURL *)baseAppSwitchURL;

/// Create an app switch URL
///
/// @param merchantID   The merchant ID
/// @param accessToken  The access token used by the venmo app to tokenize on behalf of the merchant
/// @param scheme       The return URL scheme, e.g. "com.yourcompany.Your-App.payments"
/// @param bundleName   The bundle display name for the current app
/// @param environment  The environment, e.g. "production" or "sandbox"
///
/// @return The resulting URL
+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID
                         accessToken:(NSString *)accessToken
                          sdkVersion:(NSString *)sdkVersion
                     returnURLScheme:(NSString *)scheme
                   bundleDisplayName:(NSString *)bundleName
                         environment:(NSString *)environment;

@end

NS_ASSUME_NONNULL_END
