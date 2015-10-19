#import "BTPayPalDriver_Internal.h"

#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#import "BTTokenizedPayPalAccount_Internal.h"
#import "BTPostalAddress.h"
#import "BTLogger_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTTokenizedPayPalAccount_Internal.h>
#import <BraintreeCore/BTTokenizedPayPalCheckout_Internal.h>
#import <BraintreeCore/BTPostalAddress.h>
#import <BraintreeCore/BTLogger_Internal.h>
#endif
#import <SafariServices/SafariServices.h>
#import "BTConfiguration+PayPal.h"

NSString *const BTPayPalDriverErrorDomain = @"com.braintreepayments.BTPayPalDriverErrorDomain";

static void (^appSwitchReturnBlock)(NSURL *url);

typedef NS_ENUM(NSUInteger, BTPayPalPaymentType) {
    BTPayPalPaymentTypeUnknown = 0,
    BTPayPalPaymentTypeFuturePayments,
    BTPayPalPaymentTypeCheckout,
    BTPayPalPaymentTypeBillingAgreement,
};

@interface BTPayPalDriver () <SFSafariViewControllerDelegate>
@end

@implementation BTPayPalDriver

+ (void)load {
    if (self == [BTPayPalDriver class]) {
        PayPalClass = [PayPalOneTouchCore class];
        
        [[BTAppSwitch sharedInstance] registerAppSwitchHandler:self];
        
        [[BTTokenizationService sharedService] registerType:@"PayPal" withTokenizationBlock:^(BTAPIClient *apiClient, __unused NSDictionary *options, void (^completionBlock)(id<BTTokenized> tokenization, NSError *error)) {
            BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
            driver.viewControllerPresentingDelegate = options[BTTokenizationServiceViewPresentingDelegateOption];
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
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                             code:BTPayPalDriverErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTPayPalDriver failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }
    
    [self setAuthorizationAppSwitchReturnBlock:completionBlock];
    
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }
        
        if (configuration.isBillingAgreementsEnabled) {
            // Switch to Billing Agreements flow
            BTPayPalCheckoutRequest *checkout = [[BTPayPalCheckoutRequest alloc] init];
            [self billingAgreementWithCheckoutRequest:checkout completion:completionBlock];
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
        
        if (self.apiClient.clientToken) {
            request.additionalPayloadAttributes = @{ @"client_token": self.apiClient.clientToken.originalValue };
        } else if (self.apiClient.clientKey) {
            request.additionalPayloadAttributes = @{ @"client_key": self.apiClient.clientKey };
        }
        
        
        [self informDelegateWillPerformAppSwitch];
        [request performWithAdapterBlock:^(BOOL success, NSURL *url, PayPalOneTouchRequestTarget target, NSString *clientMetadataId, NSError *error) {
            self.clientMetadataId = clientMetadataId;
            
            [self sendAnalyticsEventForInitiatingOneTouchForPaymentType:BTPayPalPaymentTypeFuturePayments withSuccess:success target:target];
            
            if (success) {
                [self performSwitchRequest:url];
                [self informDelegateDidPerformAppSwitchToTarget:target];
            } else {
                if (completionBlock) completionBlock(nil, error);
            }
        }];
    }];
}

- (void)setAuthorizationAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalAccount *account, NSError *error))completionBlock {
    [self setAppSwitchReturnBlock:completionBlock forPaymentType:BTPayPalPaymentTypeFuturePayments];
}

#pragma mark - Billing Agreement

- (void)billingAgreementWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest completion:(void (^)(BTTokenizedPayPalAccount *tokenizedCheckout, NSError *error))completionBlock {
    [self checkoutWithCheckoutRequest:checkoutRequest
                   isBillingAgreement:YES
                           completion:completionBlock];
}


- (void)setBillingAgreementAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalAccount *tokenizedAccount, NSError *error))completionBlock {
    [self setAppSwitchReturnBlock:completionBlock forPaymentType:BTPayPalPaymentTypeBillingAgreement];
}


#pragma mark - Checkout (Single Payments)

- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest completion:(void (^)(BTTokenizedPayPalAccount *tokenizedCheckout, NSError *error))completionBlock {
    [self checkoutWithCheckoutRequest:checkoutRequest
                   isBillingAgreement:NO
                           completion:completionBlock];
}

- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest
                 isBillingAgreement:(BOOL)isBillingAgreement
                         completion:(void (^)(BTTokenizedPayPalAccount *tokenizedCheckout, NSError *error))completionBlock {
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                             code:BTPayPalDriverErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTPayPalDriver failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }
    
    if (!checkoutRequest || (!isBillingAgreement && !checkoutRequest.amount)) {
        completionBlock(nil, [NSError errorWithDomain:BTPayPalDriverErrorDomain code:BTPayPalDriverErrorTypeInvalidRequest userInfo:nil]);
        return;
    }
    
    NSString *returnURI;
    NSString *cancelURI;
    
    [[self.class payPalClass] redirectURLsForCallbackURLScheme:self.returnURLScheme
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
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        if (!isBillingAgreement) {
            if (checkoutRequest.amount.stringValue) {
                parameters[@"amount"] = checkoutRequest.amount.stringValue;
            }
        }
        
        // Currency code should only be used for Hermes Checkout (one-time payment).
        // For BA, currency should not be used.
        NSString *currencyCode = checkoutRequest.currencyCode ?: configuration.json[@"paypal"][@"currencyIsoCode"].asString;
        if (!isBillingAgreement && currencyCode) {
            parameters[@"currency_iso_code"] = currencyCode;
        }
        
        if (checkoutRequest.enableShippingAddress && checkoutRequest.shippingAddress != nil) {
            BTPostalAddress *shippingAddress = checkoutRequest.shippingAddress;
            parameters[@"line1"] = shippingAddress.streetAddress;
            parameters[@"line2"] = shippingAddress.extendedAddress;
            parameters[@"city"] = shippingAddress.locality;
            parameters[@"state"] = shippingAddress.region;
            parameters[@"postal_code"] = shippingAddress.postalCode;
            parameters[@"country_code"] = shippingAddress.countryCodeAlpha2;
            parameters[@"recipient_name"] = shippingAddress.recipientName;
        }
        if (returnURI) {
            parameters[@"return_url"] = returnURI;
        }
        if (cancelURI) {
            parameters[@"cancel_url"] = cancelURI;
        }
        if ([[self.class payPalClass] clientMetadataID]) {
            parameters[@"correlation_id"] = [[self.class payPalClass] clientMetadataID];
        }
        
        NSString *url = isBillingAgreement ? @"setup_billing_agreement" : @"create_payment_resource";
        
        [self.apiClient POST:[NSString stringWithFormat:@"v1/paypal_hermes/%@",url]
                  parameters:parameters
                  completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                      
                      if (error) {
                          if (completionBlock) completionBlock(nil, error);
                          return;
                      }

                      if (isBillingAgreement) {
                          [self setBillingAgreementAppSwitchReturnBlock:completionBlock];
                      } else {
                          [self setCheckoutAppSwitchReturnBlock:completionBlock];
                      }

                      NSString *payPalClientID = configuration.json[@"paypal"][@"clientId"].asString;
                      
                      if (!payPalClientID && [self payPalEnvironmentForRemoteConfiguration:configuration.json] == PayPalEnvironmentMock) {
                          payPalClientID = @"FAKE-PAYPAL-CLIENT-ID";
                      }
                      
                      NSURL *approvalUrl = body[@"paymentResource"][@"redirectUrl"].asURL;
                      if (approvalUrl == nil) {
                          approvalUrl = body[@"agreementSetup"][@"approvalUrl"].asURL;
                      }
                      
                      PayPalOneTouchCheckoutRequest *request = nil;
                      if (isBillingAgreement) {
                          request = [self.requestFactory billingAgreementRequestWithApprovalURL:approvalUrl
                                                                                       clientID:payPalClientID
                                                                                    environment:[self payPalEnvironmentForRemoteConfiguration:configuration.json]
                                                                              callbackURLScheme:self.returnURLScheme];
                      } else {
                          request = [self.requestFactory checkoutRequestWithApprovalURL:approvalUrl
                                                                               clientID:payPalClientID
                                                                            environment:[self payPalEnvironmentForRemoteConfiguration:configuration.json]
                                                                      callbackURLScheme:self.returnURLScheme];
                      }
                      
                      
                      [self informDelegateWillPerformAppSwitch];
                      
                      [request performWithAdapterBlock:^(BOOL success, NSURL *url, PayPalOneTouchRequestTarget target, NSString *clientMetadataId, NSError *error) {
                          self.clientMetadataId = clientMetadataId;
                          
                          if (isBillingAgreement) {
                              [self sendAnalyticsEventForInitiatingOneTouchForPaymentType:BTPayPalPaymentTypeBillingAgreement withSuccess:success target:target];
                          } else {
                              [self sendAnalyticsEventForInitiatingOneTouchForPaymentType:BTPayPalPaymentTypeCheckout withSuccess:success target:target];
                          }
                          if (success) {
                              [self performSwitchRequest:url];
                              [self informDelegateDidPerformAppSwitchToTarget:target];
                          } else {
                              if (completionBlock) completionBlock(nil, error);
                          }
                      }];
                  }];
    }];
}


- (void)setCheckoutAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalAccount *tokenizedAccount, NSError *error))completionBlock {
    [self setAppSwitchReturnBlock:completionBlock forPaymentType:BTPayPalPaymentTypeCheckout];
}


#pragma mark - Helpers


- (void)setAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalAccount *tokenizedAccount, NSError *error))completionBlock
                 forPaymentType:(BTPayPalPaymentType)paymentType {
    appSwitchReturnBlock = ^(NSURL *url) {
        [self informDelegatePresentingViewControllerNeedsDismissal];
        [self informDelegateWillProcessAppSwitchReturn];
        
        // Before parsing the return URL, check whether the user cancelled by breaking
        // out of the PayPal app switch flow (e.g. "Done" button in SFSafariViewController)
        // TODO: add UI automation test
        if ([url.absoluteString isEqualToString:SFSafariViewControllerFinishedURL]) {
            if (completionBlock) completionBlock(nil, nil);
            return;
        }
        
        [[self.class payPalClass] parseResponseURL:url completionBlock:^(PayPalOneTouchCoreResult *result) {
            
            [self sendAnalyticsEventForHandlingOneTouchResult:result forPaymentType:paymentType];
            
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
                    
                    if (paymentType == BTPayPalPaymentTypeCheckout) {
                        parameters[@"paypal_account"][@"options"] = @{ @"validate": @NO };
                    }
                    if (self.clientMetadataId) {
                        parameters[@"correlation_id"] = self.clientMetadataId;
                    }
                    BTClientMetadata *metadata = [self clientMetadata];
                    parameters[@"_meta"] = @{
                                             @"source" : metadata.sourceString,
                                             @"integration" : metadata.integrationString,
                                             @"sessionId" : metadata.sessionId,
                                             };
                    
                    [self.apiClient POST:@"/v1/payment_methods/paypal_accounts"
                              parameters:parameters
                              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
                     {
                         if (error) {
                             [self sendAnalyticsEventForTokenizationFailureForPaymentType:paymentType];
                             if (completionBlock) completionBlock(nil, error);
                             return;
                         }
                         
                         [self sendAnalyticsEventForTokenizationSuccessForPaymentType:paymentType];
                         
                         BTJSON *payPalAccount = body[@"paypalAccounts"][0];
                         BTTokenizedPayPalAccount *tokenizedAccount = [self.class payPalAccountFromJSON:payPalAccount];
                         
                         if (completionBlock) completionBlock(tokenizedAccount, nil);
                     }];
                    
                    break;
                }
            }
            appSwitchReturnBlock = nil;
        }];
    };
}


- (void)performSwitchRequest:(NSURL*) appSwitchURL {
    if ([SFSafariViewController class]) {
        [self informDelegatePresentingViewControllerRequestPresent:appSwitchURL];
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

+ (BTPostalAddress *)shippingOrBillingAddressFromJSON:(BTJSON *)addressJSON {
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
    
    BTJSON *details = payPalAccount[@"details"];
    
    NSString *email = details[@"email"].asString;
    NSString *clientMetadataId = details[@"correlationId"].asString;
    // Allow email to be under payerInfo
    if (details[@"payerInfo"][@"email"].isString) { email = details[@"payerInfo"][@"email"].asString; }
    
    NSString *firstName = details[@"payerInfo"][@"firstName"].asString;
    NSString *lastName = details[@"payerInfo"][@"lastName"].asString;
    NSString *phone = details[@"payerInfo"][@"phone"].asString;
    NSString *payerId = details[@"payerInfo"][@"payerId"].asString;
    
    BTPostalAddress *shippingAddress = [self.class shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"shippingAddress"]];
    BTPostalAddress *billingAddress = [self.class shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"billingAddress"]];
    if (!shippingAddress) {
        shippingAddress = [self.class accountAddressFromJSON:details[@"payerInfo"][@"accountAddress"]];
    }
    
    // Braintree gateway has some inconsistent behavior depending on
    // the type of nonce, and sometimes returns "PayPal" for description,
    // and sometimes returns a real identifying string. The former is not
    // desirable for display. The latter is.
    // As a workaround, we ignore descriptions that look like "PayPal".
    if ([description caseInsensitiveCompare:@"PayPal"] == NSOrderedSame) {
        description = email;
    }
    
    BTTokenizedPayPalAccount *tokenizedPayPalAccount = [[BTTokenizedPayPalAccount alloc] initWithPaymentMethodNonce:nonce description:description email:email firstName:firstName lastName:lastName phone:phone billingAddress:billingAddress shippingAddress:shippingAddress clientMetadataId:clientMetadataId payerId:payerId];
    
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

- (void)informDelegatePresentingViewControllerRequestPresent:(NSURL*) appSwitchURL {
    if (self.viewControllerPresentingDelegate != nil && [self.viewControllerPresentingDelegate respondsToSelector:@selector(paymentDriver:requestsPresentationOfViewController:)]) {
        self.safariViewController = [[SFSafariViewController alloc] initWithURL:appSwitchURL];
        self.safariViewController.delegate = self;
        [self.viewControllerPresentingDelegate paymentDriver:self requestsPresentationOfViewController:self.safariViewController];
    } else {
        [[BTLogger sharedLogger] warning:@"Unable to display View Controller to continue PayPal flow. BTPayPalDriver needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set."];
    }
}

- (void)informDelegatePresentingViewControllerNeedsDismissal {
    if (self.viewControllerPresentingDelegate != nil && [self.viewControllerPresentingDelegate respondsToSelector:@selector(paymentDriver:requestsDismissalOfViewController:)]) {
        [self.viewControllerPresentingDelegate paymentDriver:self requestsDismissalOfViewController:self.safariViewController];
        self.safariViewController = nil;
    } else {
        [[BTLogger sharedLogger] warning:@"Unable to dismiss View Controller to end PayPal flow. BTPayPalDriver needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set."];
    }
}

#pragma mark - SFSafariViewControllerDelegate

static NSString * const SFSafariViewControllerFinishedURL = @"sfsafariviewcontroller://finished";

- (void)safariViewControllerDidFinish:(__unused SFSafariViewController *)controller {
    [self.class handleAppSwitchReturnURL:[NSURL URLWithString:SFSafariViewControllerFinishedURL]];
}

#pragma mark - Preflight check

- (BOOL)verifyAppSwitchWithRemoteConfiguration:(BTJSON *)configuration returnURLScheme:(NSString *)returnURLScheme error:(NSError * __autoreleasing *)error {
    
    if (!configuration[@"paypalEnabled"].isTrue) {
        [self.apiClient sendAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal is not enabled for this merchant." }];
        }
        return NO;
    }
    
    if (returnURLScheme == nil) {
        [self.apiClient sendAnalyticsEvent:@"ios.paypal-otc.preflight.nil-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a returnURLScheme. See BTAppSwitch -returnURLScheme." }];
        }
        return NO;
    }
    
    if (![[self.class payPalClass] doesApplicationSupportOneTouchCallbackURLScheme:returnURLScheme]) {
        [self.apiClient sendAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
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

+ (NSString *)eventStringForPaymentType:(BTPayPalPaymentType)paymentType {
    switch (paymentType) {
        case BTPayPalPaymentTypeBillingAgreement:
            return @"paypal-ba";
        case BTPayPalPaymentTypeFuturePayments:
            return @"paypal-future-payments";
        case BTPayPalPaymentTypeCheckout:
            return @"paypal-single-payment";
        case BTPayPalPaymentTypeUnknown:
            return nil;
    }
}

+ (NSString *)eventStringForRequestTarget:(PayPalOneTouchRequestTarget)requestTarget {
    switch (requestTarget) {
        case PayPalOneTouchRequestTargetNone:
            return @"none";
        case PayPalOneTouchRequestTargetUnknown:
            return @"unknown";
        case PayPalOneTouchRequestTargetOnDeviceApplication:
            return @"appswitch";
        case PayPalOneTouchRequestTargetBrowser:
            return @"webswitch";
    }
}

- (void)sendAnalyticsEventForInitiatingOneTouchForPaymentType:(BTPayPalPaymentType)paymentType
                                                  withSuccess:(BOOL)success
                                                       target:(PayPalOneTouchRequestTarget)target
{
    if (paymentType == BTPayPalPaymentTypeUnknown) return;
    
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.%@.initiate.%@", [self.class eventStringForPaymentType:paymentType], [self.class eventStringForRequestTarget:target], success ? @"started" : @"failed"];
    
    [self.apiClient sendAnalyticsEvent:eventName];
}

- (void)sendAnalyticsEventForHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result forPaymentType:(BTPayPalPaymentType)paymentType {
    if (paymentType == BTPayPalPaymentTypeUnknown) return;
    
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.%@", [self.class eventStringForPaymentType:paymentType], [self.class eventStringForRequestTarget:result.target]];
    
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            return [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"%@.failed", eventName]];
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                return [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"%@.canceled-with-error", eventName]];
            } else {
                return [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"%@.canceled", eventName]];
            }
        case PayPalOneTouchResultTypeSuccess:
            return [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"%@.succeeded", eventName]];
    }
}

- (void)sendAnalyticsEventForTokenizationSuccessForPaymentType:(BTPayPalPaymentType)paymentType {
    if (paymentType == BTPayPalPaymentTypeUnknown) return;
    
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.tokenize.succeeded", [self.class eventStringForPaymentType:paymentType]];
    [self.apiClient sendAnalyticsEvent:eventName];
}

- (void)sendAnalyticsEventForTokenizationFailureForPaymentType:(BTPayPalPaymentType)paymentType {
    if (paymentType == BTPayPalPaymentTypeUnknown) return;
    
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.tokenize.failed", [self.class eventStringForPaymentType:paymentType]];
    [self.apiClient sendAnalyticsEvent:eventName];
}

#pragma mark - App Switch handling

- (BOOL)isiOSAppAvailableForAppSwitch {
    return [[self.class payPalClass] isWalletAppInstalled];
}

+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return appSwitchReturnBlock != nil && [PayPalOneTouchCore canParseURL:url sourceApplication:sourceApplication];
}

+ (void)handleAppSwitchReturnURL:(NSURL *)url {
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

static Class PayPalClass;

+ (void)setPayPalClass:(Class)payPalClass {
    if ([payPalClass isSubclassOfClass:[PayPalOneTouchCore class]]) {
        PayPalClass = payPalClass;
    }
}

+ (Class)payPalClass {
    return PayPalClass;
}

@end
