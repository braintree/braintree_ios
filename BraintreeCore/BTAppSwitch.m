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

+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (@available(iOS 9.0, *)) {
        return [[BTAppSwitch sharedInstance] handleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    } else {
        return [[BTAppSwitch sharedInstance] handleOpenURL:url sourceApplication:@""];
    }
#pragma clang diagnostic pop
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[BTAppSwitch sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
#pragma clang diagnostic pop
}

+ (BOOL)handleOpenURLContext:(UIOpenURLContext *)URLContext API_AVAILABLE(ios(13.0)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[BTAppSwitch sharedInstance] handleOpenURL:URLContext.URL sourceApplication:URLContext.options.sourceApplication];
#pragma clang diagnostic pop
}

// NEXT_MAJOR_VERSION Remove this method from public header, but continue using it internally.
// Once removed, delete the code to ignore deprecation warnings (above).
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
