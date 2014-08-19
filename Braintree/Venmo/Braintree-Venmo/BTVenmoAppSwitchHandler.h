#import <Foundation/Foundation.h>
#import "BTClient.h"

@interface BTVenmoAppSwitchHandler : NSObject

@property (nonatomic, strong, readonly) BTClient *client;
@property (nonatomic, copy) NSString *callbackURLScheme;

+ (instancetype)sharedHandler;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id)delegate;

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)handleReturnURL:(NSURL *)url;

@end
