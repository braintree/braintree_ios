#import <Foundation/Foundation.h>

@interface BTAppSwitchHandler : NSObject

@property (nonatomic, copy) NSString *appSwitchCallbackURLScheme;

+ (instancetype)sharedHandler;

- (BOOL)handleAppSwitchURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end

