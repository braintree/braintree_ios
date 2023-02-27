#import "BTVenmoClient_Internal.h"
#import "BTVenmoAccountNonce_Internal.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTVenmoRequest_Internal.h"
#import "UIKit/UIKit.h"

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

@interface BTVenmoClient () <BTAppContextSwitchClient>

@property (nonatomic, copy) void (^appSwitchCompletionBlock)(BTVenmoAccountNonce *, NSError *);

@end

NSString * const BTVenmoErrorDomain = @"com.braintreepayments.BTVenmoErrorDomain";
NSString * const BTVenmoAppStoreUrl = @"https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428";
NSInteger const NetworkConnectionLostCode = -1005;

@implementation BTVenmoClient

static BTVenmoClient *appSwitchedClient;

+ (void)load {
    if (self == [BTVenmoClient class]) {
        [[BTAppContextSwitcher sharedInstance] registerAppContextSwitchClient:self];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

#pragma mark - Accessors

- (id)application NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

- (NSBundle *)bundle {
    if (!_bundle) {
        _bundle = [NSBundle mainBundle];
    }
    return _bundle;
}

- (UIDevice *)device {
    if (!_device) {
        _device = [UIDevice currentDevice];
    }
    return _device;
}

- (NSString *)returnURLScheme {
    if (!_returnURLScheme) {
        _returnURLScheme = [BTAppContextSwitcher sharedInstance].returnURLScheme;
    }
    return _returnURLScheme;
}

#pragma mark - Tokenization

- (void)tokenizeVenmoAccountWithVenmoRequest:(BTVenmoRequest *)venmoRequest completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock {
    if (!venmoRequest) {
        NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                             code:BTVenmoErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTVenmoClient failed because BTVenmoRequest is nil."}];
        completionBlock(nil, error);
        return;
    }

    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                             code:BTVenmoErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTVenmoClient failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }

    if (self.returnURLScheme == nil || [self.returnURLScheme isEqualToString:@""]) {
        NSLog(@"%@ Venmo requires a return URL scheme to be configured via [BTAppContextSwitcher setReturnURLScheme:]", [BTLogLevelDescription stringFor:BTLogLevelCritical]);
        NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                             code:BTVenmoErrorTypeAppNotAvailable
                                         userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app switch to Venmo."}];
        completionBlock(nil, error);
        return;
    } else if (!self.bundle.bundleIdentifier || ![self.returnURLScheme hasPrefix:self.bundle.bundleIdentifier]) {
        NSLog(@"%@ Venmo requires [BTAppContextSwitcher setReturnURLScheme:] to be configured to begin with your app's bundle ID (%@). Currently, it is set to (%@) ", [BTLogLevelDescription stringFor:BTLogLevelCritical], [NSBundle mainBundle].bundleIdentifier, self.returnURLScheme);
    }

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *configurationError) {
        if (configurationError) {
            completionBlock(nil, configurationError);
            return;
        }
        
        NSError *error;
        if (![self verifyAppSwitchWithConfiguration:configuration error:&error]) {
            completionBlock(nil, error);
            return;
        }
        
        NSString *merchantProfileID = venmoRequest.profileID ?: configuration.venmoMerchantID;
        NSString *bundleDisplayName = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        BTMutableClientMetadata *metadata = [self.apiClient.metadata mutableCopy];
        metadata.source = BTClientMetadataSourceVenmoApp;
        
        NSMutableDictionary *inputParams = [@{
            @"paymentMethodUsage": venmoRequest.paymentMethodUsageAsString,
            @"merchantProfileId": merchantProfileID,
            @"customerClient": @"MOBILE_APP",
            @"intent": @"CONTINUE",
//            @"collectShippingAddress": asdf,
//            @"collectBillingAddress": asdf,
//            @"totalAmount":
//            @"discountAmount":
//            @"shippingAmount":
//            @"taxAmount": asdf,
//            @"lineItems":
        } mutableCopy];
        
        if (venmoRequest.displayName) {
            inputParams[@"displayName"] = venmoRequest.displayName;
        }
        
        NSDictionary *params = @{
            @"query": @"mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
            @"variables": @{
                @"input": inputParams
            }
        };
        
        [self.apiClient POST:@"" parameters:params httpType:BTAPIClientHTTPServiceGraphQLAPI completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *err) {
            if (err) {
                if (err.code == BTCoreConstants.networkConnectionLostCode) {
                    [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.network-connection.failure"];
                }
                NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                                     code:BTVenmoErrorTypeInvalidRequestURL
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch a Venmo paymentContextID while constructing the requestURL."}];
                completionBlock(nil, error);
                return;
            }
            
            NSString *paymentContextID = [body[@"data"][@"createVenmoPaymentContext"][@"venmoPaymentContext"][@"id"] asString];
            if (paymentContextID == nil) {
                NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                                     code:BTVenmoErrorTypeInvalidRequestURL
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."}];
                completionBlock(nil, error);
                return;
            }
            
            NSURL *appSwitchURL = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:merchantProfileID
                                                                            accessToken:configuration.venmoAccessToken
                                                                        returnURLScheme:self.returnURLScheme
                                                                      bundleDisplayName:bundleDisplayName
                                                                            environment:configuration.venmoEnvironment
                                                                       paymentContextID:paymentContextID
                                                                               metadata:self.apiClient.metadata];
            
            [self performAppSwitch:appSwitchURL shouldVault:venmoRequest.vault completion:completionBlock];
        }];
    }];
}

#pragma mark - Vaulting

- (void)vaultVenmoAccountNonce:(NSString *)nonce {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"venmoAccount"] = @{
                                @"nonce": nonce
                                };
    
    [self.apiClient POST:@"v1/payment_methods/venmo_accounts"
              parameters:params
              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                  if (error) {
                      if (error.code == NetworkConnectionLostCode) {
                          [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.network-connection.failure"];
                      }
                      [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.vault.failure"];
                      self.appSwitchCompletionBlock(nil, error);
                  } else {
                      [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.vault.success"];
                      BTJSON *venmoAccountJson = body[@"venmoAccounts"][0];
                      self.appSwitchCompletionBlock([BTVenmoAccountNonce venmoAccountWithJSON:venmoAccountJson], venmoAccountJson.asError);
                  }
                  self.appSwitchCompletionBlock = nil;
    }];
}

#pragma mark - App switch

- (void)performAppSwitch:(NSURL *)appSwitchURL shouldVault:(BOOL)vault completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock {
    if (!appSwitchURL) {
        NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                             code:BTVenmoErrorTypeInvalidRequestURL
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to create Venmo app switch request URL."}];
        completionBlock(nil, error);
        return;
    }

    [self.application openURL:appSwitchURL options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
        [self invokedOpenURLSuccessfully:success shouldVault:vault completion:completionBlock];
    }];
}

- (void)invokedOpenURLSuccessfully:(BOOL)success shouldVault:(BOOL)vault completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *configurationError))completionBlock {
    self.shouldVault = success && vault;

    if (success) {
        self.appSwitchCompletionBlock = completionBlock;
        appSwitchedClient = self;
        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.success"];
    } else {
        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.error.failure"];
        NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                    code:BTVenmoErrorTypeAppSwitchFailed
                                userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app switch to Venmo."}];
        completionBlock(nil, error);
    }
}

- (BOOL)isiOSAppAvailableForAppSwitch {
    return [self.application canOpenURL:[BTVenmoAppSwitchRequestURL baseAppSwitchURL]];
}

#pragma mark - App switch return

+ (void)handleReturnURL:(NSURL *)url {
    [appSwitchedClient handleOpenURL:url];
    appSwitchedClient = nil;
}

+ (BOOL)canHandleReturnURL:(NSURL *)url {
    return [BTVenmoAppSwitchReturnURL isValidURL:url];
}

- (void)handleOpenURL:(NSURL *)url {
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceededWithPaymentContext: {
            NSDictionary *params = @{
                @"query": @"query PaymentContext($id: ID!) { node(id: $id) { ... on VenmoPaymentContext { paymentMethodId userName payerInfo { firstName lastName phoneNumber email externalId userName } } } }",
                @"variables": @{ @"id": returnURL.paymentContextID }
            };

            [self.apiClient POST:@"" parameters:params httpType:BTAPIClientHTTPServiceGraphQLAPI completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                if (error) {
                    if (error.code == NetworkConnectionLostCode) {
                        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.network-connection.failure"];
                    }
                    [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.client-failure"];
                    self.appSwitchCompletionBlock(nil, error);
                    self.appSwitchCompletionBlock = nil;
                    return;
                }

                BTVenmoAccountNonce *venmoAccountNonce = [[BTVenmoAccountNonce alloc] initWithPaymentContextJSON:body];
                [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.success"];

                if (self.shouldVault && self.apiClient.clientToken != nil) {
                    [self vaultVenmoAccountNonce:venmoAccountNonce.nonce];
                } else {
                    self.appSwitchCompletionBlock(venmoAccountNonce, nil);
                    self.appSwitchCompletionBlock = nil;
                }
            }];
            break;
        }
        case BTVenmoAppSwitchReturnURLStateSucceeded: {

            NSError *error = nil;
            if (!returnURL.nonce) {
                error = [NSError errorWithDomain:BTVenmoErrorDomain code:BTVenmoErrorTypeInvalidReturnURL userInfo:@{NSLocalizedDescriptionKey: @"Return URL is missing nonce"}];
            } else if (!returnURL.username) {
                error = [NSError errorWithDomain:BTVenmoErrorDomain code:BTVenmoErrorTypeInvalidReturnURL userInfo:@{NSLocalizedDescriptionKey: @"Return URL is missing username"}];
            }

            if (error) {
                [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.client-failure"];
                self.appSwitchCompletionBlock(nil, error);
                self.appSwitchCompletionBlock = nil;
                return;
            }

            [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.success"];

            if (self.shouldVault && self.apiClient.clientToken != nil) {
                [self vaultVenmoAccountNonce:returnURL.nonce];
            } else {
                BTJSON *json = [[BTJSON alloc] initWithValue:@{
                    @"nonce": returnURL.nonce,
                    @"details": @{@"username": returnURL.username},
                    @"description": returnURL.username
                }];
                BTVenmoAccountNonce *card = [BTVenmoAccountNonce venmoAccountWithJSON:json];
                self.appSwitchCompletionBlock(card, nil);
                self.appSwitchCompletionBlock = nil;
            }
            break;
        }
        case BTVenmoAppSwitchReturnURLStateFailed: {
            [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.failed"];
            self.appSwitchCompletionBlock(nil, returnURL.error);
            self.appSwitchCompletionBlock = nil;
            break;
        }
        case BTVenmoAppSwitchReturnURLStateCanceled: {
            [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.cancel"];
            self.appSwitchCompletionBlock(nil, nil);
            self.appSwitchCompletionBlock = nil;
            break;
        }
        default:
            // should not happen
            break;
    }
}

#pragma mark - App Store switch

- (void)openVenmoAppPageInAppStore {
    NSURL *venmoAppStoreUrl = [NSURL URLWithString:BTVenmoAppStoreUrl];
    [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.app-store.invoked"];
    [self.application openURL:venmoAppStoreUrl
                      options:[NSDictionary dictionary]
            completionHandler:nil];
}

#pragma mark - Helpers

- (BOOL)verifyAppSwitchWithConfiguration:(BTConfiguration *)configuration error:(NSError * __autoreleasing *)error {
    
    if (!configuration.isVenmoEnabled) {
        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.error.disabled"];
        if (error) {
            *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                         code:BTVenmoErrorTypeDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey:@"Venmo is not enabled for this merchant account." }];
        }
        return NO;
    }
    
    if (![self isiOSAppAvailableForAppSwitch]) {
        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.error.unavailable"];
        if (error) {
            *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                         code:BTVenmoErrorTypeAppNotAvailable
                                     userInfo:@{ NSLocalizedDescriptionKey:@"The Venmo app is not installed on this device, or it is not configured or available for app switch." }];
        }
        return NO;
    }
    
    NSString *bundleDisplayName = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!bundleDisplayName) {
        if (error) {
            *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                         code:BTVenmoErrorTypeBundleDisplayNameMissing
                                     userInfo:@{NSLocalizedDescriptionKey: @"CFBundleDisplayName must be non-nil. Please set 'Bundle display name' in your Info.plist."}];
        }
        return NO;
    }
    
    return YES;
}

@end
