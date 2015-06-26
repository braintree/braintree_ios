#import "BTAppSwitch.h"

@interface BTAppSwitch ()

// Dictionary of id <AppSwitching> keyed by @(BTPaymentAppSwitchType)
@property (nonatomic, strong) NSMutableDictionary *appSwitchingInstances;

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
        _appSwitchingInstances = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setReturnURLScheme:(NSString *)returnURLScheme {
    _returnURLScheme = returnURLScheme;
    for (id<BTAppSwitching> switchingInstance in [self.appSwitchingInstances allValues]) {
        [switchingInstance setReturnURLScheme:returnURLScheme];
    }
}

- (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    for (id<BTAppSwitching> switcher in [self.appSwitchingInstances allValues]) {
        if ([switcher canHandleReturnURL:url sourceApplication:sourceApplication]) {
            if ([switcher delegate]) {
                [switcher handleReturnURL:url];
            } else {
                // Fallback BTSwitchingDelegate here
            }
            return YES;
        }
    }
    return NO;
}

- (void)addAppSwitching:(id<BTAppSwitching>)appSwitching forApp:(BTAppType)type {
    self.appSwitchingInstances[@(type)] = appSwitching;
}

- (void)removeAppSwitchingForApp:(BTAppType)type {
    [self.appSwitchingInstances removeObjectForKey:@(type)];
}

- (id <BTAppSwitching>)appSwitchingForApp:(BTAppType)type {
    return self.appSwitchingInstances[@(type)];
}

@end
