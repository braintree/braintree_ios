#import "BTPayPalDriver_Internal.h"

#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

#import "BTAPIClient_Internal.h"
#import "BTTokenizedPayPalAccount_Internal.h"
#import "BTTokenizedPayPalCheckout_Internal.h"
#import "BTPostalAddress.h"
#import "BTLogger_Internal.h"
#import <SafariServices/SafariServices.h>

NSString *const BTPayPalDriverErrorDomain = @"com.braintreepayments.BTPayPalDriverErrorDomain";

static void (^appSwitchReturnBlock)(NSURL *url);
static SFSafariViewController *safariViewController;

@interface BTPayPalDriver ()
@end

@implementation BTPayPalDriver

+ (void)load {
    if (self == [BTPayPalDriver class]) {
        [[BTAppSwitch sharedInstance] registerAppSwitchHandler:self];

        [[BTTokenizationService sharedService] registerType:@"PayPal" withTokenizationBlock:^(BTAPIClient *apiClient, __unused NSDictionary *options, void (^completionBlock)(id<BTTokenized> tokenization, NSError *error)) {
            BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
            [driver authorizeAccountWithCompletion:completionBlock];
        }];

        [[BTTokenizationParser sharedParser] registerType:@"PayPalAccount" withParsingBlock:^id<BTTokenized> _Nullable(BTJSON * _Nonnull payPalAccount) {
            return [self payPalAccountFromJSON:payPalAccount];
        }];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        BTClientMetadataSourceType source = [self isiOSAppAvailableForAppSwitch] ? BTClientMetadataSourcePayPalApp : BTClientMetadataSourcePayPalBrowser;
        _apiClient = [apiClient copyWithSource:source integration:apiClient.metadata.integration];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

#pragma mark - Authorization (Future Payments)

- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedPayPalAccount *paymentMethod, NSError *error))completionBlock {
    [self authorizeAccountWithAdditionalScopes:[NSSet set] completion:completionBlock];
}

- (void)authorizeAccountWithAdditionalScopes:(NSSet<NSString *> *)additionalScopes completion:(void (^)(BTTokenizedPayPalAccount *, NSError *))completionBlock {

    [self setAuthorizationAppSwitchReturnBlock:completionBlock];

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }

        if (![self verifyAppSwitchWithRemoteConfiguration:configuration.json returnURLScheme:self.returnURLScheme error:&error]) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }

        PayPalOneTouchAuthorizationRequest *request =
        [self.requestFactory requestWithScopeValues:[self.defaultOAuth2Scopes setByAddingObjectsFromSet:(additionalScopes ? additionalScopes : [NSSet set])]
                                         privacyURL:configuration.json[@"paypal"][@"privacyUrl"].asURL
                                       agreementURL:configuration.json[@"paypal"][@"userAgreementUrl"].asURL
                                           clientID:[self paypalClientIdWithRemoteConfiguration:configuration.json]
                                        environment:[self payPalEnvironmentForRemoteConfiguration:configuration.json]
                                  callbackURLScheme:self.returnURLScheme];

        // TODO: add support for client key in server
        if (self.apiClient.clientToken) {
            request.additionalPayloadAttributes = @{ @"client_token": self.apiClient.clientToken.originalValue };
        } else if (self.apiClient.clientKey) {
            // TODO: remove when server has supoprt for client key
            NSString *clientToken = @"eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiIyMzQwNTZjNGE3YTQ3ZTY5NDE1Zjg1M2Y0N2Y3Mjc2ZGFiY2YyMWIxOThhZDE4ODYyODcyYzEyNTRiMjViZTZkfGNyZWF0ZWRfYXQ9MjAxNS0wOC0xMFQyMjowMjo1My4yODI1NjM2NzUrMDAwMFx1MDAyNm1lcmNoYW50X2lkPWQ4aHhxaGRnN3dyM2Y3dzJcdTAwMjZwdWJsaWNfa2V5PTIyeDh3ajZyeTRiZm50Y3ciLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZDhoeHFoZGc3d3IzZjd3Mi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbImN2diJdLCJlbnZpcm9ubWVudCI6InNhbmRib3giLCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZDhoeHFoZGc3d3IzZjd3Mi9jbGllbnRfYXBpIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhdXRoVXJsIjoiaHR0cHM6Ly9hdXRoLnZlbm1vLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhbmFseXRpY3MiOnsidXJsIjoiaHR0cHM6Ly9jbGllbnQtYW5hbHl0aWNzLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwidGhyZWVEU2VjdXJlIjp7Imxvb2t1cFVybCI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy9kOGh4cWhkZzd3cjNmN3cyL3RocmVlX2Rfc2VjdXJlL2xvb2t1cCJ9LCJwYXlwYWxFbmFibGVkIjp0cnVlLCJwYXlwYWwiOnsiZGlzcGxheU5hbWUiOiJHb2dnaW4iLCJjbGllbnRJZCI6bnVsbCwicHJpdmFjeVVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS9wcCIsInVzZXJBZ3JlZW1lbnRVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vdG9zIiwiYmFzZVVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9jaGVja291dC5wYXlwYWwuY29tIiwiZGlyZWN0QmFzZVVybCI6bnVsbCwiYWxsb3dIdHRwIjp0cnVlLCJlbnZpcm9ubWVudE5vTmV0d29yayI6dHJ1ZSwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwidW52ZXR0ZWRNZXJjaGFudCI6ZmFsc2UsImJyYWludHJlZUNsaWVudElkIjoibWFzdGVyY2xpZW50MyIsIm1lcmNoYW50QWNjb3VudElkIjoiMzI2ODJ5ZzI1OHk0Mjk3NiIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZhbHNlLCJtZXJjaGFudElkIjoiZDhoeHFoZGc3d3IzZjd3MiIsInZlbm1vIjoib2ZmIn0=";
//            request.additionalPayloadAttributes = @{ @"client_key": self.apiClient.clientKey };
            request.additionalPayloadAttributes = @{ @"client_token": clientToken };
        }


        [self informDelegateWillPerformAppSwitch];
        [request performWithAdapterBlock:^(NSURL *url) {
            [self performSwitchRequest:url];
        } completionBlock:^(BOOL success, PayPalOneTouchRequestTarget target, __unused NSString *clientMetadataId, NSError *error) {
                
            [self postAnalyticsEventForInitiatingOneTouchWithSuccess:success target:target];
            if (success) {
                [self informDelegateDidPerformAppSwitchToTarget:target];
            } else {
                if (completionBlock) completionBlock(nil, error);
            }
        }];
    }];
}

- (void)setAuthorizationAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalAccount *account, NSError *error))completionBlock
{
    appSwitchReturnBlock = ^(NSURL *url) {
        [self informDelegateWillProcessAppSwitchReturn];

        [self.payPalClass parseResponseURL:url completionBlock:^(PayPalOneTouchCoreResult *result) {
            [self postAnalyticsEventForHandlingOneTouchResult:result];

            switch (result.type) {
                case PayPalOneTouchResultTypeError:
                    if (completionBlock) completionBlock(nil, result.error);
                    break;
                case PayPalOneTouchResultTypeCancel:
                    if (result.error) {
                        [[BTLogger sharedLogger] error:@"PayPal error: %@", result.error];
                    }
                    if (completionBlock) completionBlock(nil, nil);
                    break;
                case PayPalOneTouchResultTypeSuccess: {
                    [self.apiClient POST:@"/v1/payment_methods/paypal_accounts"
                              parameters:@{ @"paypal_account": result.response,
                                            @"correlation_id": [self.payPalClass clientMetadataID],
                                            }
                              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                                  if (error) {
                                      [self postAnalyticsEventForTokenizationFailure];
                                      if (completionBlock) completionBlock(nil, error);
                                      return;
                                  }

                                  [self postAnalyticsEventForTokenizationSuccess];

                                  BTJSON *payPalAccount = body[@"paypalAccounts"][0];
                                  BTTokenizedPayPalAccount *tokenizedPayPalAccount = [[self class] payPalAccountFromJSON:payPalAccount];

                                  if (completionBlock) completionBlock(tokenizedPayPalAccount, nil);
                                  appSwitchReturnBlock = nil;
                              }];
                    break;
                }
            }
        }];
    };
}



#pragma mark - Checkout (Single Payments)

- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest completion:(void (^)(BTTokenizedPayPalCheckout *tokenizedCheckout, NSError *error))completionBlock {
    if (!checkoutRequest || !checkoutRequest.amount) {
        completionBlock(nil, [NSError errorWithDomain:BTPayPalDriverErrorDomain code:BTPayPalDriverErrorTypeInvalidRequest userInfo:nil]);
        return;
    }

    NSString *returnURI;
    NSString *cancelURI;

    [self.payPalClass redirectURLsForCallbackURLScheme:self.returnURLScheme
                                         withReturnURL:&returnURI
                                         withCancelURL:&cancelURI];
    if (!returnURI || !cancelURI) {
        completionBlock(nil, [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                                 code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                             userInfo:@{NSLocalizedFailureReasonErrorKey: @"Application may not support One Touch callback URL scheme.",
                                                        NSLocalizedRecoverySuggestionErrorKey: @"Check the return URL scheme" }]);
        return;
    }

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }

        if (![self verifyAppSwitchWithRemoteConfiguration:configuration.json
                                          returnURLScheme:self.returnURLScheme
                                                    error:&error]) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }

        NSString *currencyCode = checkoutRequest.currencyCode ?: configuration.json[@"payPal"][@"currencyIsoCode"].asString;

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (checkoutRequest.amount.stringValue) {
            parameters[@"amount"] = checkoutRequest.amount.stringValue;
        }
        if (currencyCode) {
            parameters[@"currency_iso_code"] = currencyCode;
        }
        if (returnURI) {
            parameters[@"return_url"] = returnURI;
        }
        if (cancelURI) {
            parameters[@"cancel_url"] = cancelURI;
        }
        if ([self.payPalClass clientMetadataID]) {
            parameters[@"correlation_id"] = [self.payPalClass clientMetadataID];
        }

        [self.apiClient POST:@"v1/paypal_hermes/create_payment_resource"
                  parameters:parameters
                  completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {

                      if (error) {
                          if (completionBlock) completionBlock(nil, error);
                          return;
                      }

                      [self setCheckoutAppSwitchReturnBlock:completionBlock];

                      NSString *payPalClientID = configuration.json[@"paypal"][@"clientId"].asString;

                      if (!payPalClientID && [self payPalEnvironmentForRemoteConfiguration:configuration.json] == PayPalEnvironmentMock) {
                          payPalClientID = @"FAKE-PAYPAL-CLIENT-ID";
                      }
                      PayPalOneTouchCheckoutRequest *request = [self.requestFactory requestWithApprovalURL:body[@"paymentResource"][@"redirectUrl"].asURL
                                                                                                  clientID:payPalClientID
                                                                                               environment:[self payPalEnvironmentForRemoteConfiguration:configuration.json]
                                                                                         callbackURLScheme:self.returnURLScheme];

                      [self informDelegateWillPerformAppSwitch];

                      [request performWithAdapterBlock:^(NSURL *url) {
                          [self performSwitchRequest:url];
                      } completionBlock:^(BOOL success, PayPalOneTouchRequestTarget target, __unused NSString *clientMetadataId, NSError *error) {
                          [self postAnalyticsEventForSinglePaymentForInitiatingOneTouchWithSuccess:success target:target];
                          if (success) {
                              [self informDelegateDidPerformAppSwitchToTarget:target];
                          } else {
                              if (completionBlock) completionBlock(nil, error);
                          }
                      }];
                  }];
    }];
}

- (void)setCheckoutAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalCheckout *tokenizedCheckout, NSError *error))completionBlock
{
    appSwitchReturnBlock = ^(NSURL *url) {
        [self informDelegateWillProcessAppSwitchReturn];

        [self.payPalClass parseResponseURL:url completionBlock:^(PayPalOneTouchCoreResult *result) {

            [self postAnalyticsEventForSinglePaymentForHandlingOneTouchResult:result];

            switch (result.type) {
                case PayPalOneTouchResultTypeError:
                    if (completionBlock) completionBlock(nil, result.error);
                    break;
                case PayPalOneTouchResultTypeCancel:
                    if (result.error) {
                        [[BTLogger sharedLogger] error:@"PayPal error: %@", result.error];
                    }
                    if (completionBlock) completionBlock(nil, nil);
                    break;
                case PayPalOneTouchResultTypeSuccess: {

                    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                    parameters[@"paypal_account"] = [result.response mutableCopy];
                    parameters[@"paypal_account"][@"options"] = @{ @"validate": @NO };
                    if ([self.payPalClass clientMetadataID]) {
                        parameters[@"correlation_id"] = [self.payPalClass clientMetadataID];
                    }
                    BTClientMetadata *metadata = [self clientMetadata];
                    parameters[@"_meta"] =  @{ @"source": metadata.sourceString,
                                               @"integration": metadata.integrationString };


                    [self.apiClient POST:@"/v1/payment_methods/paypal_accounts"
                              parameters:parameters
                              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                                  if (error) {
                                      [self postAnalyticsEventForTokenizationFailureForSinglePayment];
                                      if (completionBlock) completionBlock(nil, error);
                                      return;
                                  }

                                  [self postAnalyticsEventForTokenizationSuccessForSinglePayment];

                                  BTJSON *payPalAccount = body[@"paypalAccounts"][0];
                                  NSString *nonce = payPalAccount[@"nonce"].asString;
                                  NSString *description = payPalAccount[@"description"].asString;

                                  BTJSON *details = payPalAccount[@"details"];
                                  NSString *email = details[@"email"].asString;
                                  // Allow email to be under payerInfo
                                  if (details[@"payerInfo"][@"email"].isString) { email = details[@"payerInfo"][@"email"].asString; }
                                  NSString *firstName = details[@"payerInfo"][@"firstName"].asString;
                                  NSString *lastName = details[@"payerInfo"][@"lastName"].asString;
                                  NSString *phone = details[@"payerInfo"][@"phone"].asString;

                                  BTPostalAddress *shippingAddress = [self shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"shippingAddress"]];
                                  BTPostalAddress *billingAddress = [self shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"billingAddress"]];
                                  if (!billingAddress) {
                                      billingAddress = [[self class] accountAddressFromJSON:details[@"payerInfo"][@"accountAddress"]];
                                  }

                                  // Braintree gateway has some inconsistent behavior depending on
                                  // the type of nonce, and sometimes returns "PayPal" for description,
                                  // and sometimes returns a real identifying string. The former is not
                                  // desirable for display. The latter is.
                                  // As a workaround, we ignore descriptions that look like "PayPal".
                                  if ([description caseInsensitiveCompare:@"PayPal"] == NSOrderedSame) {
                                      description = email;
                                  }

                                  BTTokenizedPayPalCheckout *tokenizedCheckout = [[BTTokenizedPayPalCheckout alloc] initWithPaymentMethodNonce:nonce
                                                                                                                                   description:description
                                                                                                                                         email:email
                                                                                                                                     firstName:firstName
                                                                                                                                      lastName:lastName
                                                                                                                                         phone:phone
                                                                                                                                billingAddress:billingAddress
                                                                                                                               shippingAddress:shippingAddress];

                                  if (completionBlock) completionBlock(tokenizedCheckout, nil);
                              }];
                    break;
                }
            }
            appSwitchReturnBlock = nil;
        }];
    };
}

#pragma mark - Helpers

- (void)performSwitchRequest:(NSURL*) appSwitchURL {
    if([SFSafariViewController class]){
        safariViewController = [[SFSafariViewController alloc] initWithURL:appSwitchURL];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:safariViewController animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:appSwitchURL];
    }
}

- (NSString *)payPalEnvironmentForRemoteConfiguration:(BTJSON *)configuration {
    NSString *btPayPalEnvironmentName = configuration[@"paypal"][@"environment"].asString;
    if ([btPayPalEnvironmentName isEqualToString:@"offline"]) {
        return PayPalEnvironmentMock;
    } else if ([btPayPalEnvironmentName isEqualToString:@"live"]) {
        return PayPalEnvironmentProduction;
    } else {
        // Fall back to mock when configuration has an unsupported value for environment, e.g. "custom"
        // Instead of returning btPayPalEnvironmentName
        return PayPalEnvironmentMock;
    }
}

- (NSString *)paypalClientIdWithRemoteConfiguration:(BTJSON *)configuration {
    if ([configuration[@"paypal"][@"environment"].asString isEqualToString:@"offline"] && !configuration[@"paypal"][@"clientId"].isString) {
        return @"mock-paypal-client-id";
    } else {
        return configuration[@"paypal"][@"clientId"].asString;
    }
}

- (BTClientMetadata *)clientMetadata {
    BTMutableClientMetadata *metadata = [self.apiClient.metadata mutableCopy];

    if ([self isiOSAppAvailableForAppSwitch]) {
        metadata.source = BTClientMetadataSourcePayPalApp;
    } else {
        metadata.source = BTClientMetadataSourcePayPalBrowser;
    }

    return [metadata copy];
}

- (NSSet *)defaultOAuth2Scopes {
    return [NSSet setWithObjects:@"https://uri.paypal.com/services/payments/futurepayments", @"email", nil];
}

+ (BTPostalAddress *)accountAddressFromJSON:(BTJSON *)addressJSON {
    if (!addressJSON.isObject) {
        return nil;
    }

    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.recipientName = addressJSON[@"recipientName"].asString; // Likely to be nil
    address.streetAddress = addressJSON[@"street1"].asString;
    address.extendedAddress = addressJSON[@"street2"].asString;
    address.locality = addressJSON[@"city"].asString;
    address.region = addressJSON[@"state"].asString;
    address.postalCode = addressJSON[@"postalCode"].asString;
    address.countryCodeAlpha2 = addressJSON[@"country"].asString;

    return address;
}

- (BTPostalAddress *)shippingOrBillingAddressFromJSON:(BTJSON *)addressJSON {
    if (!addressJSON.isObject) {
        return nil;
    }

    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.recipientName = addressJSON[@"recipientName"].asString; // Likely to be nil
    address.streetAddress = addressJSON[@"line1"].asString;
    address.extendedAddress = addressJSON[@"line2"].asString;
    address.locality = addressJSON[@"city"].asString;
    address.region = addressJSON[@"state"].asString;
    address.postalCode = addressJSON[@"postalCode"].asString;
    address.countryCodeAlpha2 = addressJSON[@"countryCode"].asString;

    return address;
}

+ (BTTokenizedPayPalAccount *)payPalAccountFromJSON:(BTJSON *)payPalAccount {
    NSString *nonce = payPalAccount[@"nonce"].asString;
    NSString *description = payPalAccount[@"description"].asString;
    NSString *email = payPalAccount[@"details"][@"email"].asString;
    if (payPalAccount[@"details"][@"payerInfo"][@"email"].isString) {
        email = payPalAccount[@"details"][@"payerInfo"][@"email"].asString;
    }
    BTPostalAddress *accountAddress = [self accountAddressFromJSON:payPalAccount[@"details"][@"payerInfo"][@"accountAddress"]];

    // Braintree gateway has some inconsistent behavior depending on
    // the type of nonce, and sometimes returns "PayPal" for description,
    // and sometimes returns a real identifying string. The former is not
    // desirable for display. The latter is.
    // As a workaround, we ignore descriptions that look like "PayPal".
    if ([description caseInsensitiveCompare:@"PayPal"] == NSOrderedSame) {
        description = email;
    }

    BTTokenizedPayPalAccount *tokenizedPayPalAccount = [[BTTokenizedPayPalAccount alloc] initWithPaymentMethodNonce:nonce description:description email:email accountAddress:accountAddress];
    return tokenizedPayPalAccount;
}

#pragma mark - Delegate Informers

- (void)informDelegateWillPerformAppSwitch {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppSwitchWillSwitchNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.delegate respondsToSelector:@selector(appSwitcherWillPerformAppSwitch:)]) {
        [self.delegate appSwitcherWillPerformAppSwitch:self];
    }
}

- (void)informDelegateDidPerformAppSwitchToTarget:(PayPalOneTouchRequestTarget)target {
    BTAppSwitchTarget appSwitchTarget;
    switch (target) {
        case PayPalOneTouchRequestTargetBrowser:
            appSwitchTarget = BTAppSwitchTargetWebBrowser;
            break;
        case PayPalOneTouchRequestTargetOnDeviceApplication:
            appSwitchTarget = BTAppSwitchTargetNativeApp;
            break;
        case PayPalOneTouchRequestTargetNone:
        case PayPalOneTouchRequestTargetUnknown:
            appSwitchTarget = BTAppSwitchTargetUnknown;
            // Should never happen
            break;
    }

    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppSwitchDidSwitchNotification object:self userInfo:@{ BTAppSwitchNotificationTargetKey : @(appSwitchTarget) } ];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.delegate respondsToSelector:@selector(appSwitcher:didPerformSwitchToTarget:)]) {
        [self.delegate appSwitcher:self didPerformSwitchToTarget:appSwitchTarget];
    }
}

- (void)informDelegateWillProcessAppSwitchReturn {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppSwitchWillProcessPaymentInfoNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.delegate respondsToSelector:@selector(appSwitcherWillProcessPaymentInfo:)]) {
        [self.delegate appSwitcherWillProcessPaymentInfo:self];
    }
}

#pragma mark - Preflight check

- (BOOL)verifyAppSwitchWithRemoteConfiguration:(BTJSON *)configuration returnURLScheme:(NSString *)returnURLScheme error:(NSError * __autoreleasing *)error {

    if (!configuration[@"paypalEnabled"].isTrue) {
        [self.apiClient postAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal is not enabled for this merchant." }];
        }
        return NO;
    }

    if (returnURLScheme == nil) {
        [self.apiClient postAnalyticsEvent:@"ios.paypal-otc.preflight.nil-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a returnURLScheme. See BTAppSwitch -returnURLScheme." }];
        }
        return NO;
    }

    if (![self.payPalClass doesApplicationSupportOneTouchCallbackURLScheme:returnURLScheme]) {
        [self.apiClient postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: @"Application may not support One Touch callback URL scheme",
                                                NSLocalizedRecoverySuggestionErrorKey: @"Verify that BTAppSwitch -returnURLScheme is set to this app's bundle id" }];
        }
        return NO;
    }

    return YES;
}

#pragma mark - Analytics Helpers

- (void)postAnalyticsEventForInitiatingOneTouchWithSuccess:(BOOL)success target:(PayPalOneTouchRequestTarget)target {
    if (success) {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.started"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.initiate.started"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.started"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];
        }
    } else {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.failed"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.initiate.failed"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.failed"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.failed"];
        }
    }
}

- (void)postAnalyticsEventForHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result {
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.failed"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.failed"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.failed"];
            }
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled-with-error"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.canceled-with-error"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.canceled-with-error"];
                }
            } else {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.canceled"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.canceled"];
                }
            }
        case PayPalOneTouchResultTypeSuccess:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.unknown.succeeded"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.succeeded"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.succeeded"];
            }
    }
}

- (void)postAnalyticsEventForTokenizationSuccess {
    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.succeeded"];
}

- (void)postAnalyticsEventForTokenizationFailure {
    return [self.apiClient postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.failed"];
}

- (void)postAnalyticsEventForTokenizationSuccessForSinglePayment {
    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.succeeded"];
}

- (void)postAnalyticsEventForTokenizationFailureForSinglePayment {
    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.failed"];
}

- (void)postAnalyticsEventForSinglePaymentForInitiatingOneTouchWithSuccess:(BOOL)success target:(PayPalOneTouchRequestTarget)target {
    if (success) {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.none.initiate.started"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.initiate.started"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.initiate.started"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.initiate.started"];
        }
    } else {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.none.initiate.failed"];
            case PayPalOneTouchRequestTargetUnknown:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.initiate.failed"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.initiate.failed"];
            case PayPalOneTouchRequestTargetBrowser:
                return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.initiate.failed"];
        }
    }
}

- (void)postAnalyticsEventForSinglePaymentForHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result {
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.failed"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.failed"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.failed"];
            }
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.canceled-with-error"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.canceled-with-error"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.canceled-with-error"];
                }
            } else {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.canceled"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.canceled"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.canceled"];
                }
            }
        case PayPalOneTouchResultTypeSuccess:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.unknown.succeeded"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.succeeded"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [self.apiClient postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.succeeded"];
            }
    }
}

#pragma mark - App Switch handling

- (BOOL)isiOSAppAvailableForAppSwitch {
    return [self.payPalClass isWalletAppInstalled];
}

+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return appSwitchReturnBlock != nil && [PayPalOneTouchCore canParseURL:url sourceApplication:sourceApplication];
}

+ (void)handleAppSwitchReturnURL:(NSURL *)url {
    if (safariViewController) {
        [safariViewController dismissViewControllerAnimated:YES completion:^{
            safariViewController = nil;
        }];
    }
    if (appSwitchReturnBlock) {
        appSwitchReturnBlock(url);
    }
}

- (NSString *)returnURLScheme {
    if (!_returnURLScheme) {
        _returnURLScheme = [[BTAppSwitch sharedInstance] returnURLScheme];
    }
    return _returnURLScheme;
}

#pragma mark - Internal

- (BTPayPalRequestFactory *)requestFactory {
    if (!_requestFactory) {
        _requestFactory = [[BTPayPalRequestFactory alloc] init];
    }
    return _requestFactory;
}

@synthesize payPalClass = _payPalClass;

- (Class)payPalClass {
    if (!_payPalClass) {
        _payPalClass = [PayPalOneTouchCore class];
    }
    return _payPalClass;
}

- (void)setPayPalClass:(Class)payPalClass {
    if ([payPalClass isSubclassOfClass:[PayPalOneTouchCore class]]) {
        _payPalClass = payPalClass;
    }
}

@end
