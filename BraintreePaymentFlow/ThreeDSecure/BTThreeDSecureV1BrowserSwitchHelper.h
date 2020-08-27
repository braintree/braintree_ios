#import <Foundation/Foundation.h>
@class BTThreeDSecureRequest;
@class BTThreeDSecureLookup;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureV1BrowserSwitchHelper : NSObject

+ (NSURL *)urlWithScheme:(NSString *)appReturnURLScheme
               assetsURL:(NSString *)assetsURL
     threeDSecureRequest:(BTThreeDSecureRequest *)threeDSecureRequest
      threeDSecureLookup:(BTThreeDSecureLookup *)threeDSecureLookup;

@end

NS_ASSUME_NONNULL_END
