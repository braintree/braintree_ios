#import "BTAppSwitch.h"
#import <UIKit/UIKit.h>

@interface BTAppSwitch ()

@property (nonatomic, strong) NSMutableSet *appSwitchHandlers;

@end

@implementation BTAppSwitch

+ (instancetype)sharedInstance {
    static BTAppSwitch *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTAppSwitch alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _appSwitchHandlers = [NSMutableSet set];
    }
    return self;
}

+ (BOOL)handleReturnURL:(NSURL *)url options:(NSDictionary *)options {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    return [[[self class] sharedInstance] handleReturnURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
#else
    return [[[self class] sharedInstance] handleReturnURL:url sourceApplication:nil];
#endif
}

+ (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [[[self class] sharedInstance] handleReturnURL:url sourceApplication:sourceApplication];
}

- (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    for (Class<BTAppSwitchHandler> handlerClass in self.appSwitchHandlers) {
        if ([handlerClass canHandleAppSwitchReturnURL:url sourceApplication:sourceApplication]) {
            [handlerClass handleAppSwitchReturnURL:url];
            return YES;
        }
    }
    return NO;
}

-(void)registerAppSwitchHandler:(Class<BTAppSwitchHandler>)handler {
    if (!handler) return;
    [self.appSwitchHandlers addObject:handler];
}

- (void)unregisterAppSwitchHandler:(Class<BTAppSwitchHandler>)handler {
    [self.appSwitchHandlers removeObject:handler];
}

@end
