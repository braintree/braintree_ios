#import <Foundation/Foundation.h>

@class BTOfflineClientBackend;

extern NSString *const BTOfflineModeClientApiBaseURL;
extern NSString *const BTOfflineModeClientApiAuthURL;

@interface BTOfflineModeURLProtocol : NSURLProtocol

+ (NSURL *)clientApiBaseURL;

+ (void)setBackend:(BTOfflineClientBackend *)backend;
+ (BTOfflineClientBackend *)backend;

@end
