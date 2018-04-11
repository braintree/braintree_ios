#import "BTAppSwitch.h"
#import <UIKit/UIKit.h>

NSString * const BTAppSwitchWillSwitchNotification = @"com.braintreepayments.BTAppSwitchWillSwitchNotification";
NSString * const BTAppSwitchDidSwitchNotification = @"com.braintreepayments.BTAppSwitchDidSwitchNotification";
NSString * const BTAppSwitchWillProcessPaymentInfoNotification = @"com.braintreepayments.BTAppSwitchWillProcessPaymentInfoNotification";
NSString * const BTAppSwitchNotificationTargetKey = @"BTAppSwitchNotificationTargetKey";
NSString * const BTAppContextWillSwitchNotification = @"com.braintreepayments.BTAppContextWillSwitchNotification";
NSString * const BTAppContextDidReturnNotification = @"com.braintreepayments.BTAppContextDidReturnNotification";

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

+ (void)setReturnURLScheme:(NSString *)returnURLScheme {
    [BTAppSwitch sharedInstance].returnURLScheme = returnURLScheme;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 9.0, *)) {
#endif
        return [[[self class] sharedInstance] handleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    }
    // This code should technically never run due to the way the compiler macros are setup, but need to return a value here.
    return [[[self class] sharedInstance] handleOpenURL:url sourceApplication:@""];
#endif
}
#else
+ (BOOL)handleOpenURL:(NSURL *)url options:(__unused NSDictionary *)options {
    return [[[self class] sharedInstance] handleOpenURL:url sourceApplication:nil];
}
#endif

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [[[self class] sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
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
