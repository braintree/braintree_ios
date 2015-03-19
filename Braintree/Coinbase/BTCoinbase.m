#import <coinbase-official/CoinbaseOAuth.h>

#import "BTCoinbase.h"
#import "BTClient_Internal.h"
#import "BTAppSwitchErrors.h"

@interface BTCoinbase ()
@property (nonatomic, strong) BTClient *client;
@end

@implementation BTCoinbase

@synthesize returnURLScheme = _returnURLScheme;
@synthesize delegate = _delegate;

+ (instancetype)sharedCoinbase {
    static BTCoinbase *coinbase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coinbase = [[self alloc] init];
    });
    return coinbase;
}

- (BOOL)providerAppSwitchAvailableForClient:(BTClient *)client {
    return self.returnURLScheme && [self appSwitchAvailableForClient:client] && [CoinbaseOAuth isAppOAuthAuthenticationAvailable];
}

#pragma mark Helpers

- (NSURL *)redirectUri {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [self returnURLScheme];
    components.path = @"/vzero/auth/coinbase/redirect";
    components.host = @"x-callback-url";
    return [components URL];
}

- (NSError *)errorWithCode:(BTAppSwitchErrorCode)code localizedDescription:(NSString *)localizedDescription {
    NSDictionary *userInfo;
    if (localizedDescription) {
        userInfo = @{NSLocalizedDescriptionKey: localizedDescription };
    }
    return [NSError errorWithDomain:BTAppSwitchErrorDomain code:code userInfo:userInfo];
}


#pragma mark BTAppSwitching

- (BOOL)appSwitchAvailableForClient:(BTClient *)client {
    return client.configuration.coinbaseEnabled;
}

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate error:(NSError *__autoreleasing *)error {
    if (!self.returnURLScheme) {
        [self.client postAnalyticsEvent:@"ios.coinbase.initiate.failed"];
        if (error != NULL) {
            *error = [self errorWithCode:BTAppSwitchErrorIntegrationReturnURLScheme localizedDescription:@"Coinbase is not available"];
        }
        return NO;
    }

    if (![self appSwitchAvailableForClient:client]) {
        [self.client postAnalyticsEvent:@"ios.coinbase.initiate.failed"]; //we should distinguish between errors here
        if (error != NULL) {
            *error = [self errorWithCode:BTAppSwitchErrorDisabled localizedDescription:@"Coinbase is not available"];
        }
        return NO;
    }

    self.client = client;
    self.delegate = delegate;

    [self postAnalyticsSwitchEventWithString:@"started"];
    BOOL startSuccessful = [CoinbaseOAuth startOAuthAuthenticationWithClientId:client.configuration.coinbaseClientId
                                                                         scope:client.configuration.coinbaseScope
                                                                   redirectUri:[self.redirectUri absoluteString]
                                                                          meta:(client.configuration.coinbaseMerchantAccount ? @{ @"authorizations_merchant_account": client.configuration.coinbaseMerchantAccount } : nil)];

    if (!startSuccessful) {
        [self postAnalyticsSwitchEventWithString:@"failed"];
        if (error != NULL) {
            *error = [self errorWithCode:BTAppSwitchErrorFailed localizedDescription:@"Coinbase is not available"];
        }
    } else {
        [self postAnalyticsSwitchEventWithString:@"succeeded"];
    }

    return startSuccessful;
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(__unused NSString *)sourceApplication {
    NSURL *redirectURL = self.redirectUri;
    BOOL schemeMatches = [[url.scheme lowercaseString] isEqualToString:[redirectURL.scheme lowercaseString]];
    BOOL hostMatches = [url.host isEqualToString:redirectURL.host];
    BOOL pathMatches = [url.path isEqualToString:redirectURL.path];
    return schemeMatches && hostMatches && pathMatches;
}

- (void)handleReturnURL:(NSURL *)url {
    if (![self canHandleReturnURL:url sourceApplication:nil]) {
        return;
    }
    [CoinbaseOAuth finishOAuthAuthenticationForUrl:url
                                          clientId:self.client.configuration.coinbaseClientId
                                      clientSecret:nil
                                        completion:^(id response, NSError *error) {
                                            if (error) {
                                                [self postAnalyticsSwitchEventWithString:@"denied"];
                                                [self informDelegateDidFailWithError:error];
                                            } else {
                                                [self postAnalyticsSwitchEventWithString:@"authorized"];
                                                [self.client saveCoinbaseAccount:response
                                                                         success:^(BTCoinbasePaymentMethod *coinbasePaymentMethod) {
                                                                             [self informDelegateDidCreatePaymentMethod:coinbasePaymentMethod];
                                                                         } failure:^(NSError *error) {
                                                                             [self informDelegateDidFailWithError:error];
                                                                         }];
                                            }
                                        }];
}


#pragma mark Delegate Informers

- (void)informDelegateDidFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.coinbase.tokenize.failed"];
    if ([self.delegate respondsToSelector:@selector(appSwitcher:didFailWithError:)]) {
        [self.delegate appSwitcher:self didFailWithError:error];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTCoinbasePaymentMethod *)paymentMethod {
    [self.client postAnalyticsEvent:@"ios.coinbase.tokenize.succeeded"];
    if ([self.delegate respondsToSelector:@selector(appSwitcher:didCreatePaymentMethod:)]) {
        [self.delegate appSwitcher:self didCreatePaymentMethod:paymentMethod];
    }
}


#pragma mark Analytics Helpers

- (void)postAnalyticsSwitchEventWithString:(NSString *)event {
    if (event) {
        NSString *defaultSwitch = [CoinbaseOAuth isAppOAuthAuthenticationAvailable] ? @"appswitch" : @"webswitch";
        NSString *switchEvent = [NSString stringWithFormat:@"ios.coinbase.%@.%@", defaultSwitch , event];
        [self.client postAnalyticsEvent:switchEvent];
    }
}

@end
