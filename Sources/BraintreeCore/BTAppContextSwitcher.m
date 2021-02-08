#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTAppContextSwitcher.h>
#else
#import <BraintreeCore/BTAppContextSwitcher.h>
#endif

#import <UIKit/UIKit.h>

@interface BTAppContextSwitcher ()

@property (nonatomic, strong) NSMutableSet *appContextSwitchDrivers;

@end

@implementation BTAppContextSwitcher

+ (instancetype)sharedInstance {
    static BTAppContextSwitcher *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTAppContextSwitcher alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _appContextSwitchDrivers = [NSMutableSet set];
    }
    return self;
}

+ (void)setReturnURLScheme:(NSString *)returnURLScheme {
    [BTAppContextSwitcher sharedInstance].returnURLScheme = returnURLScheme;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[BTAppContextSwitcher sharedInstance] handleOpenURL:url];
}

+ (BOOL)handleOpenURLContext:(UIOpenURLContext *)URLContext API_AVAILABLE(ios(13.0)) {
    return [[BTAppContextSwitcher sharedInstance] handleOpenURL:URLContext.URL];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    for (Class<BTAppContextSwitchDriver> driverClass in self.appContextSwitchDrivers) {
        if ([driverClass canHandleReturnURL:url]) {
            [driverClass handleReturnURL:url];
            return YES;
        }
    }
    return NO;
}

- (void)registerAppContextSwitchDriver:(Class<BTAppContextSwitchDriver>)driver {
    if (!driver) return;
    [self.appContextSwitchDrivers addObject:driver];
}

@end
