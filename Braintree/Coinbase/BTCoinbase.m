#import "BTAppSwitch.h"
#import "BTCoinbase.h"
#import "BTClient_Internal.h"
#import "BTAppSwitchErrors.h"
#import "BTCoinbaseOAuth.h"

@interface BTCoinbase ()
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, assign) BTCoinbaseOAuthAuthenticationMechanism authenticationMechanism;
@end

@implementation BTCoinbase

@synthesize returnURLScheme = _returnURLScheme;
@synthesize delegate = _delegate;

+ (void)load {
    if (self == [BTCoinbase class]) {
        [[BTAppSwitch sharedInstance] addAppSwitching:[BTCoinbase sharedCoinbase] forApp:BTAppTypeCoinbase];
    }
}

+ (instancetype)sharedCoinbase {
    static BTCoinbase *coinbase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coinbase = [[self alloc] init];
    });
    return coinbase;
}

- (BOOL)providerAppSwitchAvailableForClient:(BTClient *)client {
    return self.returnURLScheme && [self appSwitchAvailableForClient:client] && [BTCoinbaseOAuth isAppOAuthAuthenticationAvailable];
}

- (BOOL)isProviderAppInstalled {
    return [BTCoinbaseOAuth isAppOAuthAuthenticationAvailable];
}

#pragma mark Helpers

- (NSURL *)redirectUri {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [self returnURLScheme];
    components.path = @"/vzero/auth/coinbase/redirect";
    components.host = @"x-callback-url";
    return [components URL];
}


#pragma mark BTAppSwitching

- (BOOL)appSwitchAvailableForClient:(BTClient *)client {
    return client.configuration.coinbaseEnabled == YES && self.disabled == NO;
}

// In this context, "AppSwitch" includes both browser switch and provider app switch
- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate error:(NSError *__autoreleasing *)error {
    self.client = client;
    self.delegate = delegate;

    [self.client postAnalyticsEvent:@"ios.coinbase.initiate.started"];

    if (!self.returnURLScheme) {
        [self.client postAnalyticsEvent:@"ios.coinbase.initiate.invalid-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTAppSwitchErrorDomain code:BTAppSwitchErrorIntegrationReturnURLScheme
                                     userInfo:@{NSLocalizedDescriptionKey: @"Coinbase is not available",
                                                NSLocalizedFailureReasonErrorKey: @"Invalid return URL scheme",
                                                NSLocalizedRecoverySuggestionErrorKey: @"Add scheme to Info.plist and use +[Braintree setReturnURLScheme:]"}];
        }
        return NO;
    }

    if (![self appSwitchAvailableForClient:client]) {
        [self.client postAnalyticsEvent:@"ios.coinbase.initiate.unavailable"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTAppSwitchErrorDomain code:BTAppSwitchErrorDisabled
                                     userInfo:@{NSLocalizedDescriptionKey: @"Coinbase is not available",
                                                NSLocalizedFailureReasonErrorKey: @"Configuration does not enable Coinbase",
                                                NSLocalizedRecoverySuggestionErrorKey: @"Enable Coinbase in your Braintree Control Panel"}];
        }
        return NO;
    }

    self.authenticationMechanism = [BTCoinbaseOAuth startOAuthAuthenticationWithClientId:client.configuration.coinbaseClientId
                                                                                 scope:client.configuration.coinbaseScope
                                                                           redirectUri:[self.redirectUri absoluteString]
                                                                                  meta:(client.configuration.coinbaseMerchantAccount ? @{ @"authorizations_merchant_account": client.configuration.coinbaseMerchantAccount } : nil)];

    switch (self.authenticationMechanism) {
        case BTCoinbaseOAuthMechanismNone:
            [self.client postAnalyticsEvent:@"ios.coinbase.initiate.failed"];
            if (error != NULL) {
                *error = [NSError errorWithDomain:BTAppSwitchErrorDomain code:BTAppSwitchErrorFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"Coinbase is not available",
                                                    NSLocalizedFailureReasonErrorKey: @"Unable to perform app switch"}];
            }
            break;
        case BTCoinbaseOAuthMechanismApp:
            [self.client postAnalyticsEvent:@"ios.coinbase.appswitch.started"];
            break;
        case BTCoinbaseOAuthMechanismBrowser:
            [self.client postAnalyticsEvent:@"ios.coinbase.webswitch.started"];
            break;
    }

    return self.authenticationMechanism != BTCoinbaseOAuthMechanismNone;
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

    [BTCoinbaseOAuth finishOAuthAuthenticationForUrl:url
                                          clientId:self.client.configuration.coinbaseClientId
                                      clientSecret:nil
                                        completion:^(id response, NSError *error)
     {
         BTCoinbaseOAuthAuthenticationMechanism mechanism = self.authenticationMechanism;
         if (error) {
             if ([error.domain isEqualToString:BTCoinbaseErrorDomain] && error.code == BTCoinbaseOAuthError && [error.userInfo[BTCoinbaseOAuthErrorUserInfoKey] isEqual:@"access_denied"]) {
                 switch(mechanism) {
                     case BTCoinbaseOAuthMechanismApp: [self.client postAnalyticsEvent:@"ios.coinbase.appswitch.denied"]; break;
                     case BTCoinbaseOAuthMechanismBrowser: [self.client postAnalyticsEvent:@"ios.coinbase.webswitch.denied"]; break;
                     case BTCoinbaseOAuthMechanismNone: [self.client postAnalyticsEvent:@"ios.coinbase.unknown.denied"]; break;
                 }
                 [self informDelegateDidCancel];
             } else {
                 switch(mechanism) {
                     case BTCoinbaseOAuthMechanismApp: [self.client postAnalyticsEvent:@"ios.coinbase.appswitch.failed"]; break;
                     case BTCoinbaseOAuthMechanismBrowser: [self.client postAnalyticsEvent:@"ios.coinbase.webswitch.failed"]; break;
                     case BTCoinbaseOAuthMechanismNone: [self.client postAnalyticsEvent:@"ios.coinbase.unknown.failed"]; break;
                 }
                 [self informDelegateDidFailWithError:error];
             }
         } else {
             switch(mechanism) {
                 case BTCoinbaseOAuthMechanismApp: [self.client postAnalyticsEvent:@"ios.coinbase.appswitch.authorized"]; break;
                 case BTCoinbaseOAuthMechanismBrowser: [self.client postAnalyticsEvent:@"ios.coinbase.webswitch.authorized"]; break;
                 case BTCoinbaseOAuthMechanismNone: [self.client postAnalyticsEvent:@"ios.coinbase.unknown.authorized"]; break;
             }
             [self informDelegateWillCreatePaymentMethod];

             NSMutableDictionary *mutableResponse = [response mutableCopy];
             mutableResponse[@"redirect_uri"] = [self.redirectUri absoluteString];
             response = mutableResponse;
             [[self clientWithMetadataForAuthenticationMechanism:mechanism] saveCoinbaseAccount:response
                                                                                   storeInVault:self.storeInVault
                                                                                        success:^(BTCoinbasePaymentMethod *coinbasePaymentMethod) {
                                                                                            [self.client postAnalyticsEvent:@"ios.coinbase.tokenize.succeeded"];
                                                                                            [self informDelegateDidCreatePaymentMethod:coinbasePaymentMethod];
                                                                                        } failure:^(NSError *error) {
                                                                                            [self.client postAnalyticsEvent:@"ios.coinbase.tokenize.failed"];
                                                                                            [self informDelegateDidFailWithError:error];
                                                                                        }];
         }
     }];
}


#pragma mark Delegate Informers

- (void)informDelegateWillCreatePaymentMethod {
    if ([self.delegate respondsToSelector:@selector(appSwitcherWillCreatePaymentMethod:)]) {
        [self.delegate appSwitcherWillCreatePaymentMethod:self];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(appSwitcher:didFailWithError:)]) {
        [self.delegate appSwitcher:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(appSwitcherDidCancel:)]) {
        [self.delegate appSwitcherDidCancel:self];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTCoinbasePaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(appSwitcher:didCreatePaymentMethod:)]) {
        [self.delegate appSwitcher:self didCreatePaymentMethod:paymentMethod];
    }
}

#pragma mark Helpers

- (BTClient *)clientWithMetadataForAuthenticationMechanism:(BTCoinbaseOAuthAuthenticationMechanism)authenticationMechanism {
    return [self.client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        switch (authenticationMechanism) {
            case BTCoinbaseOAuthMechanismApp:
                metadata.source = BTClientMetadataSourceCoinbaseApp;
                break;
            case BTCoinbaseOAuthMechanismBrowser:
                metadata.source = BTClientMetadataSourceCoinbaseBrowser;
                break;
            default:
                metadata.source = BTClientMetadataSourceUnknown;
                break;
        }
    }];
}

@end
