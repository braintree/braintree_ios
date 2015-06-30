#import "BTPayPalDriver.h"
#import "BTAPIClient.h"
#import "BTPayPalAppSwitchHandler.h"

@interface BTPayPalDriver ()
@property (nonatomic, strong) BTAPIClient *client;
@end

@implementation BTPayPalDriver

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    self = [super init];
    if (self) {
        // TODO how do we get the base URL? from configuration?
        NSURL *baseURL = [NSURL URLWithString:@"http://example.com"];
        _client = [[BTAPIClient alloc] initWithBaseURL:baseURL authorizationFingerprint:configuration.key];
    }
    return self;
}

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration apiClient:(nonnull BTAPIClient *)client {
    self = [self initWithConfiguration:configuration];
    if (self) {
        _client = client;
    }
    return self;
}
    
- (void)authorizeAccountWithCompletion:(nonnull void (^)(BTTokenizedPayPalAccount * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

- (void)authorizeAccountWithAdditionalScopes:(nonnull NSSet<NSString *> *)additionalScopes completion:(nonnull void (^)(BTTokenizedPayPalAccount * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

- (void)checkoutWithCheckoutRequest:(nonnull BTPayPalCheckoutRequest *)checkoutRequest completion:(nonnull void (^)(BTTokenizedPayPalCheckout * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

@end
