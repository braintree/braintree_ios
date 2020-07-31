#import <Foundation/Foundation.h>
#import "BTThreeDSecureRequest_Internal.h"
#import "BTThreeDSecureLookupNew.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureV1BrowserSwitchHelper : NSObject

+ (NSURL *)urlWithScheme:(NSString *)appReturnURLScheme
               assetsURL:(NSString *)assetsURL
     threeDSecureRequest:(BTThreeDSecureRequest *)threeDSecureRequest
      threeDSecureLookup:(BTThreeDSecureLookupNew *)threeDSecureLookup;

@end

NS_ASSUME_NONNULL_END
