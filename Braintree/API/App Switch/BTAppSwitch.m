#import "BTAppSwitch.h"

@interface BTAppSwitch ()

@property (nonatomic, readwrite, strong) NSMutableSet *appSwitchingInstances;

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
        _appSwitchingInstances = [NSMutableSet set];
    }
    return self;
}

- (void)setReturnURLScheme:(NSString *)returnURLScheme {
    _returnURLScheme = returnURLScheme;
    for (id<BTAppSwitching> switchingInstance in [self.appSwitchingInstances allObjects]) {
        [switchingInstance setReturnURLScheme:returnURLScheme];
    }
}

- (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    for (id<BTAppSwitching> switcher in [self.appSwitchingInstances allObjects]) {
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

- (void)addAppSwitching:(id<BTAppSwitching>)appSwitching {
    [self.appSwitchingInstances addObject:appSwitching];
    [appSwitching setReturnURLScheme:self.returnURLScheme];
}

- (void)removeAppSwitching:(id<BTAppSwitching>)appSwitching {
    [self.appSwitchingInstances removeObject:appSwitching];
}


@end
