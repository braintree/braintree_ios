#import "BTPayPalDriver.h"

#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

#import "BTConfiguration_Internal.h"
#import "BTAnalyticsClient.h"
#import "BTAPIClient.h"
#import "BTPayPalAppSwitchHandler.h"
#import "BTTokenizedPayPalAccount_Internal.h"
#import "BTPostalAddress_Internal.h"

static void (^BTPayPalHandleURLContinuation)(NSURL *url);

@interface BTPayPalDriver ()
@property (nonatomic, strong) BTAPIClient *client;
@property (nonatomic, strong) BTConfiguration *configuration;
@end

@implementation BTPayPalDriver

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    self = [super init];
    if (self) {
        // TODO how do we get the base URL? from configuration?
        NSURL *baseURL = [NSURL URLWithString:@"http://example.com"];
        _client = [[BTAPIClient alloc] initWithBaseURL:baseURL authorizationFingerprint:configuration.key];
        self.configuration = configuration;
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

- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedPayPalAccount *paymentMethod, NSError *error))completionBlock {
    [self authorizeAccountWithAdditionalScopes:[NSSet set] completion:completionBlock];
}

- (void)authorizeAccountWithAdditionalScopes:(NSSet<NSString *> *)additionalScopes completion:(void (^)(BTTokenizedPayPalAccount *, NSError *))completionBlock {

    BTPayPalHandleURLContinuation = ^(NSURL *url){
        [self informDelegateWillProcessAppSwitchResult];

        [PayPalOneTouchCore parseResponseURL:url
                             completionBlock:^(PayPalOneTouchCoreResult *result) {
                                 [self postAnalyticsEventForHandlingOneTouchResult:result];

                                 switch (result.type) {
                                     case PayPalOneTouchResultTypeError:
                                         if (completionBlock) {
                                             completionBlock(nil, result.error);
                                         }
                                         break;
                                     case PayPalOneTouchResultTypeCancel:
                                         if (result.error) {
                                             // TODO: Log error
                                             return;
                                         }
                                         if (completionBlock) {
                                             completionBlock(nil, nil);
                                         }
                                         break;
                                     case PayPalOneTouchResultTypeSuccess: {
                                         BTAPIClient *client = self.client;

                                         BTClientMetadata *clientMetadata = [self clientMetadataForResult:result];
                                         [client POST:@"v1/payment_methods/paypal_accounts"
                                           parameters:@{ @"paypal_account": result.response,
                                                         @"correlation_id": [PayPalOneTouchCore clientMetadataID],
                                                         @"_meta": @{ @"source": clientMetadata.sourceString,
                                                                      @"integration": clientMetadata.integrationString } }
                                           completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                                               if (error) {
                                                   [self postAnalyticsEventForTokenizationFailure];
                                                   if (completionBlock) {
                                                       completionBlock(nil, error);
                                                   }
                                                   return;
                                               }

                                               [self postAnalyticsEventForTokenizationSuccess];

                                               BTJSON *payPalAccount = body[@"paypalAccounts"][0];

                                               // TODO use the existing value transformer to get payer info
                                               NSString *email, *firstName, *lastName, *phone;
                                               BTPostalAddress *billingAddress, *shippingAddress;
                                               NSDictionary *payerInfoDict = payPalAccount[@"details"][@"payerInfo"].asDictionary;
                                               if (payerInfoDict[@"email"]) { email = payerInfoDict[@"email"]; } // Allow email to be under payerInfo
                                               if (payerInfoDict[@"firstName"]) { firstName = payerInfoDict[@"firstName"]; }
                                               if (payerInfoDict[@"lastName"]) { lastName = payerInfoDict[@"lastName"]; }
                                               if (payerInfoDict[@"phone"]) { phone = payerInfoDict[@"phone"]; }
                                               if (payerInfoDict[BTPostalAddressKeyAccountAddress]) {
                                                   NSDictionary *addressDictionary = payerInfoDict[BTPostalAddressKeyAccountAddress];
                                                   billingAddress = [[BTPostalAddress alloc] init];
                                                   billingAddress.recipientName = addressDictionary[BTPostalAddressKeyRecipientName]; // Likely nil, but doesn't hurt
                                                   billingAddress.streetAddress = addressDictionary[BTPostalAddressKeyStreet1];
                                                   billingAddress.extendedAddress = addressDictionary[BTPostalAddressKeyStreet2];
                                                   billingAddress.locality = addressDictionary[BTPostalAddressKeyCity];
                                                   billingAddress.region = addressDictionary[BTPostalAddressKeyState];
                                                   billingAddress.postalCode = addressDictionary[BTPostalAddressKeyPostalCode];
                                                   billingAddress.countryCodeAlpha2 = addressDictionary[BTPostalAddressKeyCountry];
                                               }
                                               if (payerInfoDict[BTPostalAddressKeyBillingAddress]) {
                                                   NSDictionary *addressDictionary = payerInfoDict[BTPostalAddressKeyBillingAddress];
                                                   billingAddress = [[BTPostalAddress alloc] init];
                                                   billingAddress.recipientName = addressDictionary[BTPostalAddressKeyRecipientName]; // Likely nil, but doesn't hurt
                                                   billingAddress.streetAddress = addressDictionary[BTPostalAddressKeyLine1];
                                                   billingAddress.extendedAddress = addressDictionary[BTPostalAddressKeyLine2];
                                                   billingAddress.locality = addressDictionary[BTPostalAddressKeyCity];
                                                   billingAddress.region = addressDictionary[BTPostalAddressKeyState];
                                                   billingAddress.postalCode = addressDictionary[BTPostalAddressKeyPostalCode];
                                                   billingAddress.countryCodeAlpha2 = addressDictionary[BTPostalAddressKeyCountryCode];
                                               }
                                               if (payerInfoDict[BTPostalAddressKeyShippingAddress]) {
                                                   NSDictionary *addressDictionary = payerInfoDict[BTPostalAddressKeyShippingAddress];
                                                   shippingAddress = [[BTPostalAddress alloc] init];
                                                   shippingAddress.recipientName = addressDictionary[BTPostalAddressKeyRecipientName];
                                                   shippingAddress.streetAddress = addressDictionary[BTPostalAddressKeyLine1];
                                                   shippingAddress.extendedAddress = addressDictionary[BTPostalAddressKeyLine2];
                                                   shippingAddress.locality = addressDictionary[BTPostalAddressKeyCity];
                                                   shippingAddress.region = addressDictionary[BTPostalAddressKeyState];
                                                   shippingAddress.postalCode = addressDictionary[BTPostalAddressKeyPostalCode];
                                                   shippingAddress.countryCodeAlpha2 = addressDictionary[BTPostalAddressKeyCountryCode];
                                               }

                                               BTTokenizedPayPalAccount *tokenizedPayPalAccount = [[BTTokenizedPayPalAccount alloc] initWithPaymentMethodNonce:payPalAccount[@"nonce"].asString
                                                                                                                                                   description:payPalAccount[@"email"].asString
                                                                                                                                                         email:payPalAccount[@"email"].asString
                                                                                                                                                     firstName:firstName
                                                                                                                                                      lastName:lastName
                                                                                                                                                billingAddress:billingAddress
                                                                                                                                               shippingAddress:shippingAddress];

                                               if (completionBlock) {
                                                   completionBlock(tokenizedPayPalAccount, nil);
                                               }

                                               BTPayPalHandleURLContinuation = nil;
                                           }];
                                         break;
                                     }
                                 }
                             }];
    };

    [self.configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        PayPalOneTouchAuthorizationRequest *request =
        [PayPalOneTouchAuthorizationRequest requestWithScopeValues:[self.defaultOAuth2Scopes setByAddingObjectsFromSet:(additionalScopes ? additionalScopes : [NSSet set])]
                                                        privacyURL:remoteConfiguration[@"paypal"][@"privacyUrl"].asURL
                                                      agreementURL:remoteConfiguration[@"paypal"][@"userAgreementUrl"].asURL
                                                          clientID:[self paypalClientIdWithRemoteConfiguration:remoteConfiguration]
                                                       environment:[self payPalEnvironmentForRemoteConfiguration:remoteConfiguration]
                                                 callbackURLScheme:self.configuration.returnURLScheme];

        // At this time, the Braintree client_token is required by the temporary Braintree Future Payments consent webpage.
        request.additionalPayloadAttributes = @{ @"client_token": self.clientToken };

        [self informDelegateWillPerformAppSwitch];
        [request performWithCompletionBlock:^(BOOL success, PayPalOneTouchRequestTarget target, NSError *error) {
            [self postAnalyticsEventForInitiatingOneTouchWithSuccess:success target:target];
            if (success) {
                [self informDelegateDidPerformAppSwitchToTarget:target];
            } else {
                if (completionBlock) {
                    completionBlock(nil, error);
                }
            }
        }];
    }];
}

- (void)checkoutWithCheckoutRequest:(nonnull BTPayPalCheckoutRequest *)checkoutRequest completion:(nonnull void (^)(BTTokenizedPayPalCheckout * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

#pragma mark - Helpers

- (NSString *)payPalEnvironmentForRemoteConfiguration:(BTJSON *)remoteConfiguration {
    NSString *btPayPalEnvironmentName = remoteConfiguration[@"paypal"][@"environment"].asString;
    if ([btPayPalEnvironmentName isEqualToString:@"offline"]) {
        return PayPalEnvironmentMock;
    } else if ([btPayPalEnvironmentName isEqualToString:@"live"]) {
        return PayPalEnvironmentProduction;
    } else {
        return btPayPalEnvironmentName;
    }
}

- (NSString *)paypalClientIdWithRemoteConfiguration:(BTJSON *)remoteConfiguration {
    if ([remoteConfiguration[@"paypal"][@"environment"].asString isEqualToString:@"offline"] && !remoteConfiguration[@"paypal"][@"clientId"].isString) {
        return @"mock-paypal-client-id";
    } else {
        return remoteConfiguration[@"paypal"][@"clientId"].asString;
    }
}

- (BTClientMetadata *)clientMetadataForResult:(PayPalOneTouchCoreResult *)result {
    BTClientMutableMetadata *metadata = [self.configuration.clientMetadata mutableCopy];

    if ([PayPalOneTouchCore isWalletAppInstalled]) {
        metadata.source = BTClientMetadataSourcePayPalApp;
    } else {
        metadata.source = BTClientMetadataSourcePayPalBrowser;
    }

    switch (result.target) {
        case PayPalOneTouchRequestTargetNone:
        case PayPalOneTouchRequestTargetUnknown:
            metadata.source = BTClientMetadataSourceUnknown;
            break;
        case PayPalOneTouchRequestTargetBrowser:
            metadata.source = BTClientMetadataSourcePayPalBrowser;
            break;
        case PayPalOneTouchRequestTargetOnDeviceApplication:
            metadata.source = BTClientMetadataSourcePayPalBrowser;
            break;
    }

    return [metadata copy];
}

- (BTClientMetadata *)metadataForResult:(PayPalOneTouchCoreResult *)result {
    BTClientMutableMetadata *metadata = [self.configuration.clientMetadata mutableCopy];
    switch (result.target) {
        case PayPalOneTouchRequestTargetNone:
        case PayPalOneTouchRequestTargetUnknown:
            metadata.source = BTClientMetadataSourceUnknown;
            break;
        case PayPalOneTouchRequestTargetBrowser:
            metadata.source = BTClientMetadataSourcePayPalBrowser;
            break;
        case PayPalOneTouchRequestTargetOnDeviceApplication:
            metadata.source = BTClientMetadataSourcePayPalBrowser;
            break;
    }
    return metadata;
}

- (NSSet *)defaultOAuth2Scopes {
    return [NSSet setWithObjects:@"https://uri.paypal.com/services/payments/futurepayments", @"email", nil];
}


#pragma mark - Delegate Informers

- (void)informDelegateWillPerformAppSwitch {
    if ([self.delegate respondsToSelector:@selector(payPalDriverWillPerformAppSwitch:)]) {
        [self.delegate payPalDriverWillPerformAppSwitch:self];
    }
}

- (void)informDelegateDidPerformAppSwitchToTarget:(PayPalOneTouchRequestTarget)target {
    if ([self.delegate respondsToSelector:@selector(payPalDriver:didPerformAppSwitchToTarget:)]) {
        switch (target) {
            case PayPalOneTouchRequestTargetBrowser:
                [self.delegate payPalDriver:self didPerformAppSwitchToTarget:BTPayPalDriverAppSwitchTargetBrowser];
                break;
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                [self.delegate payPalDriver:self didPerformAppSwitchToTarget:BTPayPalDriverAppSwitchTargetPayPalApp];
                break;
            default:
                // Should never happen.
                break;
        }
    }
}

- (void)informDelegateWillProcessAppSwitchResult {
    if ([self.delegate respondsToSelector:@selector(payPalDriverWillProcessAppSwitchResult:)]) {
        [self.delegate payPalDriverWillProcessAppSwitchResult:self];
    }
}

#pragma mark - 

- (BOOL)verifyAppSwitchWithRemoteConfiguration:(BTJSON *)remoteConfiguration returnURLScheme:(NSString *)returnURLScheme error:(NSError * __autoreleasing *)error {

    if (!remoteConfiguration[@"paypalEnabled"].isTrue) {
        [self.analyticsClient postAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorCodePayPalDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal is not enabled for this merchant." }];
        }
        return NO;
    }

    if (returnURLScheme == nil) {
        [self.analyticsClient postAnalyticsEvent:@"ios.paypal-otc.preflight.nil-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorCodeIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a returnURLScheme. See +[Braintree setReturnURLScheme:]." }];
        }
        return NO;
    }

    if (![PayPalOneTouchCore doesApplicationSupportOneTouchCallbackURLScheme:returnURLScheme]) {
        [self.analyticsClient postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
        if (error != NULL) {
            NSString *errorMessage = [NSString stringWithFormat:@"Cannot app switch to PayPal. Verify that the return URL scheme (%@) starts with this app's bundle id, and that the PayPal app is installed.", returnURLScheme];
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorCodeIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
        }
        return NO;
    }

    return YES;
}

#pragma mark Analytics Helpers

- (BTAnalyticsClient *)analyticsClient {
    static BTAnalyticsClient *analyticsClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analyticsClient = [[BTAnalyticsClient alloc] initWithConfiguration:self.configuration];
    });
    return analyticsClient;
}

- (void)postAnalyticsEventForInitiatingOneTouchWithSuccess:(BOOL)success target:(PayPalOneTouchRequestTarget)target {
    if (success) {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.started"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.initiate.started"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.started"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];
        }
    } else {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.failed"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.initiate.failed"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.failed"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.failed"];
        }
    }
}

- (void)postAnalyticsEventForHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result {
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.failed"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.failed"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.failed"];
            }
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled-with-error"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.canceled-with-error"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.canceled-with-error"];
                }
            } else {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.canceled"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.canceled"];
                }
            }
        case PayPalOneTouchResultTypeSuccess:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.succeeded"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.succeeded"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.succeeded"];
            }
    }
}

- (void)postAnalyticsEventForTokenizationSuccess {
    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.succeeded"];
}

- (void)postAnalyticsEventForTokenizationFailure {
    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.failed"];
}

- (void)postAnalyticsEventForTokenizationSuccessForSinglePayment {
    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.succeeded"];
}

- (void)postAnalyticsEventForTokenizationFailureForSinglePayment:(BTClient *)client {
    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.failed"];
}

- (void)postAnalyticsEventForSinglePaymentForInitiatingOneTouchWithSuccess:(BOOL)success target:(PayPalOneTouchRequestTarget)target {
    if (success) {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.none.initiate.started"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.initiate.started"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.initiate.started"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.initiate.started"];
        }
    } else {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.none.initiate.failed"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.initiate.failed"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.initiate.failed"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.initiate.failed"];
        }
    }
}

- (void)postAnalyticsEventForSinglePaymentForHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result {
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.failed"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.failed"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.failed"];
            }
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.canceled-with-error"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.canceled-with-error"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.canceled-with-error"];
                }
            } else {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.canceled"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.canceled"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.canceled"];
                }
            }
        case PayPalOneTouchResultTypeSuccess:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.succeeded"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.succeeded"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.analyticsClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.succeeded"];
            }
    }
}

#pragma mark - App Switch handling

+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return BTPayPalHandleURLContinuation != nil && [PayPalOneTouchCore canParseURL:url sourceApplication:sourceApplication];
}

+ (void)handleAppSwitchReturnURL:(NSURL *)url {
    if (BTPayPalHandleURLContinuation) {
        BTPayPalHandleURLContinuation(url);
    }
}

@end
