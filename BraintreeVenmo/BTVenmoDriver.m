#import "BTConfiguration+Venmo.h"
#import "BTVenmoDriver_Internal.h"
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTAppSwitch.h>
#import <BraintreeCore/BTClientMetadata.h>
#import <BraintreeCore/BTTokenizationService.h>
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import <UIKit/UIKit.h>

@interface BTVenmoDriver ()
@property (nonatomic, copy) void (^appSwitchCompletionBlock)(BTVenmoTokenizedCard *, NSError *);
@end

NSString * const BTVenmoDriverErrorDomain = @"com.braintreepayments.BTVenmoDriverErrorDomain";

@implementation BTVenmoDriver

static BTVenmoDriver *appSwitchedDriver;

+ (void)initialize {
    [[BTAppSwitch sharedInstance] registerAppSwitchHandler:self];
    [[BTTokenizationService sharedService] registerType:@"Venmo" withTokenizationBlock:^(BTAPIClient *apiClient, NSDictionary *options, void (^completionBlock)(id<BTTokenized> tokenization, NSError *error)) {
        BTVenmoDriver *driver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];
        [driver tokenizeVenmoCardWithCompletion:completionBlock];
    }];
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = [apiClient copyWithSource:BTClientMetadataSourceVenmoApp integration:apiClient.metadata.integration];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

#pragma mark - Accessors

- (id)application {
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

- (NSString *)returnURLScheme {
    if (!_returnURLScheme) {
        _returnURLScheme = [BTAppSwitch sharedInstance].returnURLScheme;
    }
    return _returnURLScheme;
}

#pragma mark - Tokenization

- (void)tokenizeVenmoCardWithCompletion:(void (^)(BTVenmoTokenizedCard *tokenizedCard, NSError *configurationError))completionBlock {

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

        BTMutableClientMetadata *metadata = [self.apiClient.metadata mutableCopy];
        metadata.source = BTClientMetadataSourceVenmoApp;
        BOOL offline = NO; // TODO
        NSString *bundleDisplayName = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];

        if (configuration.json[@"merchantId"].isError) {
            completionBlock(nil, configuration.json[@"merchantId"].asError);
        }

        NSURL *appSwitchURL = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:configuration.json[@"merchantId"].asString
                                                                    returnURLScheme:self.returnURLScheme
                                                                  bundleDisplayName:bundleDisplayName
                                                                            offline:offline];

        [self informDelegateWillPerformAppSwitch];
        BOOL success = [self.application openURL:appSwitchURL];
        if (success) {
            [self informDelegateDidPerformAppSwitch];
            self.appSwitchCompletionBlock = completionBlock;
            appSwitchedDriver = self;
            [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.initiate.success"];
        } else {
            [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.failure"];
            error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
                                        code:BTVenmoDriverErrorTypeAppSwitchFailed
                                    userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app switch to Venmo."}];
            completionBlock(nil, error);
        }
    }];
}

#pragma mark - App switch

- (BOOL)isiOSAppAvailableForAppSwitch {
    return [self.application canOpenURL:[BTVenmoAppSwitchRequestURL baseAppSwitchURL]];
}

+ (void)handleAppSwitchReturnURL:(NSURL *)url {
    [appSwitchedDriver handleReturnURL:url];
    appSwitchedDriver = nil;
}

+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        BTJSON *venmoConfiguration = configuration.json[@"venmo"];
        if (venmoConfiguration.isString) {
            [self.apiClient postAnalyticsEvent:[NSString stringWithFormat:@"ios.venmo.appswitch.handle.%@", venmoConfiguration.asString]];
        }
    }];

    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded: {
            [self informDelegateWillProcessAppSwitchReturn];
            [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.authorized"];

            if (!self.apiClient.clientJWT) {
                NSError *error = nil;
                if (!returnURL.nonce) {
                    error = [NSError errorWithDomain:BTVenmoDriverErrorDomain code:BTVenmoDriverErrorTypeInvalidReturnURL userInfo:@{NSLocalizedDescriptionKey: @"Return URL is missing nonce"}];
                }
                if (error) {
                    [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.client-failure"];
                    self.appSwitchCompletionBlock(nil, error);
                    self.appSwitchCompletionBlock = nil;
                    return;
                }

                [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.success"];

                BTJSON *json = [[BTJSON alloc] initWithValue:@{
                                                               @"nonce": returnURL.nonce,
                                                               @"description": @"Card from Venmo"
                                                               }];
                BTVenmoTokenizedCard *card = [BTVenmoTokenizedCard cardWithJSON:json];
                self.appSwitchCompletionBlock(card, nil);
                self.appSwitchCompletionBlock = nil;
            } else {
                // Assume we have a JWT
                [self.apiClient GET:[NSString stringWithFormat:@"v1/payment_methods/%@", returnURL.nonce]
                         parameters:@{}
                         completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                             if (error) {
                                 [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.client-failure"];
                                 self.appSwitchCompletionBlock(nil, error);
                                 self.appSwitchCompletionBlock = nil;
                                 return;
                             }

                             [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.success"];

                             BTJSON *cardJSON = body[@"paymentMethods"][0];
                             if (cardJSON.isError) {
                                 self.appSwitchCompletionBlock(nil, cardJSON.asError);
                             } else {
                                 BTVenmoTokenizedCard *card = [BTVenmoTokenizedCard cardWithJSON:cardJSON];
                                 self.appSwitchCompletionBlock(card, nil);
                             }
                             self.appSwitchCompletionBlock = nil;
                         }];
            }
            break;
        }
        case BTVenmoAppSwitchReturnURLStateFailed: {
            [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.error"];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[NSUnderlyingErrorKey] = returnURL.error;
            userInfo[NSLocalizedDescriptionKey] = @"App switch failed";
            self.appSwitchCompletionBlock(nil, [NSError errorWithDomain:BTVenmoDriverErrorDomain
                                                                   code:BTVenmoDriverErrorTypeAppSwitchFailed
                                                               userInfo:userInfo]);
            self.appSwitchCompletionBlock = nil;
            break;
        }
        case BTVenmoAppSwitchReturnURLStateCanceled:
            [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.handle.cancel"];
            self.appSwitchCompletionBlock(nil, nil);
            self.appSwitchCompletionBlock = nil;
            break;
        default:
            // should not happen
            break;
    }
}

#pragma mark - Helpers

- (BOOL)verifyAppSwitchWithConfiguration:(BTConfiguration *)configuration error:(NSError * __autoreleasing *)error {

    if (!configuration.isVenmoEnabled) {
        [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.initiate.disabled"];
        if (error) {
            *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
                                         code:BTVenmoDriverErrorTypeDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey:@"Venmo is not enabled for this merchant account." }];
        }
        return NO;
    }

    if (![self isiOSAppAvailableForAppSwitch]) {
        [self.apiClient postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.unavailable"];
        if (error) {
            *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
                                         code:BTVenmoDriverErrorTypeAppNotAvailable
                                     userInfo:@{ NSLocalizedDescriptionKey:@"The Venmo app is not installed on this device, or it is not configured or available for app switch." }];
        }
        return NO;
    }

    NSString *bundleDisplayName = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!bundleDisplayName) {
        if (error) {
            *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
                                         code:BTVenmoDriverErrorTypeBundleDisplayNameMissing
                                     userInfo:@{NSLocalizedDescriptionKey: @"CFBundleDisplayName must be non-nil. Please set 'Bundle display name' in your Info.plist."}];
        }
        return NO;
    }

    return YES;
}

#pragma mark - Delegate Informers

- (void)informDelegateWillPerformAppSwitch {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTPaymentDriverWillAppSwitchNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.delegate respondsToSelector:@selector(paymentDriverWillPerformAppSwitch:)]) {
        [self.delegate paymentDriverWillPerformAppSwitch:self];
    }
}

- (void)informDelegateDidPerformAppSwitch {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTPaymentDriverDidAppSwitchNotification object:self userInfo:@{ BTPaymentDriverAppSwitchNotificationTargetKey : @(BTAppSwitchTargetNativeApp) } ];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.delegate respondsToSelector:@selector(paymentDriver:didPerformAppSwitchToTarget:)]) {
        [self.delegate paymentDriver:self didPerformAppSwitchToTarget:BTAppSwitchTargetNativeApp];
    }
}

- (void)informDelegateWillProcessAppSwitchReturn {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTPaymentDriverWillProcessPaymentInfoNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.delegate respondsToSelector:@selector(paymentDriverWillProcessPaymentInfo:)]) {
        [self.delegate paymentDriverWillProcessPaymentInfo:self];
    }
}


@end

