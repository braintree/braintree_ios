#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTAppContextSwitcher.h>
#else
#import <BraintreeCore/BTAppContextSwitcher.h>
#endif

#import <UIKit/UIKit.h>

@interface BTAppContextSwitcher ()

@property (nonatomic, strong) NSMutableSet *appSwitchHandlers;

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
        _appSwitchHandlers = [NSMutableSet set];
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
    for (Class<BTAppContextSwitchHandler> handlerClass in self.appSwitchHandlers) {
        if ([handlerClass canHandleAppSwitchReturnURL:url]) {
            [handlerClass handleAppSwitchReturnURL:url];
            return YES;
        }
    }
    return NO;
}

- (void)registerAppContextSwitchHandler:(Class<BTAppContextSwitchHandler>)handler {
    if (!handler) return;
    [self.appSwitchHandlers addObject:handler];
}

- (void)unregisterAppContextSwitchHandler:(Class<BTAppContextSwitchHandler>)handler {
    [self.appSwitchHandlers removeObject:handler];
}

@end
