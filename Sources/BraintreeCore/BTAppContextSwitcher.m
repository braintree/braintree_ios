#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTAppContextSwitcher.h>
#else
#import <BraintreeCore/BTAppContextSwitcher.h>
#endif

#import <UIKit/UIKit.h>

@interface BTAppContextSwitcher ()

@property (nonatomic, strong) NSMutableSet *appContextSwitchClients;

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
        _appContextSwitchClients = [NSMutableSet set];
    }
    return self;
}

+ (void)setReturnURLScheme:(NSString *)returnURLScheme {
    [BTAppContextSwitcher sharedInstance].returnURLScheme = returnURLScheme;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[BTAppContextSwitcher sharedInstance] handleOpenURL:url];
}

+ (BOOL)handleOpenURLContext:(UIOpenURLContext *)URLContext {
    return [[BTAppContextSwitcher sharedInstance] handleOpenURL:URLContext.URL];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    for (Class<BTAppContextSwitchClient> clientClass in self.appContextSwitchClients) {
        if ([clientClass canHandleReturnURL:url]) {
            [clientClass handleReturnURL:url];
            return YES;
        }
    }
    return NO;
}

- (void)registerAppContextSwitchClient:(Class<BTAppContextSwitchClient>)client {
    if (!client) return;
    [self.appContextSwitchClients addObject:client];
}

@end
