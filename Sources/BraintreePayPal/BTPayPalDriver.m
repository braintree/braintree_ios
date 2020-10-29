#import "BTPayPalDriver_Internal.h"
#import "BTConfiguration+PayPal.h"
#import "BTPayPalLineItem.h"
#import "BTPayPalAccountNonce_Internal.h"
#import "BTPayPalRequest.h"
#import "BTPayPalCreditFinancing_Internal.h"
#import "BTPayPalCreditFinancingAmount_Internal.h"

#if SWIFT_PACKAGE
#import "BraintreeCore.h"
#import "../BraintreeCore/BTAPIClient_Internal.h"
#import "../BraintreeCore/BTLogger_Internal.h"
#import "PayPalDataCollector.h"
#import "../PayPalDataCollector/PPDataCollector_Internal.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTLogger_Internal.h>
#import <PayPalDataCollector/PayPalDataCollector.h>
#import <PayPalDataCollector/PPDataCollector_Internal.h>
#endif

#import <SafariServices/SafariServices.h>

NSString *const BTPayPalDriverErrorDomain = @"com.braintreepayments.BTPayPalDriverErrorDomain";
NSString *const BTRedirectURLHostAndPath = @"onetouch/v1/";

/**
 This environment MUST be used for App Store submissions.
 */
NSString * _Nonnull const PayPalEnvironmentProduction = @"live";

/**
 Sandbox: Uses the PayPal sandbox for transactions. Useful for development.
 */
NSString * _Nonnull const PayPalEnvironmentSandbox = @"sandbox";

/**
 Mock: Mock mode. Does not submit transactions to PayPal. Fakes successful responses. Useful for unit tests.
 */
NSString * _Nonnull const PayPalEnvironmentMock = @"mock";

@interface BTPayPalDriver ()

@property (nonatomic, assign) BOOL becameActiveAfterSFAuthenticationSessionModal;

@end

@implementation BTPayPalDriver

+ (void)load {
    if (self == [BTPayPalDriver class]) {
        [[BTPaymentMethodNonceParser sharedParser] registerType:@"PayPalAccount" withParsingBlock:^BTPaymentMethodNonce * _Nullable(BTJSON * _Nonnull payPalAccount) {
            return [self payPalAccountFromJSON:payPalAccount];
        }];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalBrowser integration:apiClient.metadata.integration];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(applicationDidBecomeActive:)
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)applicationDidBecomeActive:(__unused NSNotification *)notification {
    if (self.isSFAuthenticationSessionStarted) {
        self.becameActiveAfterSFAuthenticationSessionModal = YES;
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Billing Agreement

- (void)requestBillingAgreement:(BTPayPalRequest *)request
                     completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
    [self requestPayPalCheckout:request
             isBillingAgreement:YES
                     completion:completionBlock];
}

#pragma mark - Express Checkout (One-Time Payments)

- (void)requestOneTimePayment:(BTPayPalRequest *)request
                   completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
    [self requestPayPalCheckout:request
             isBillingAgreement:NO
                     completion:completionBlock];
}

#pragma mark - Helpers

/// A "Hermes checkout" is used by both Billing Agreements (Vault) and One-Time Payments (Checkout)
- (void)requestPayPalCheckout:(BTPayPalRequest *)request
           isBillingAgreement:(BOOL)isBillingAgreement
                   completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                             code:BTPayPalDriverErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTPayPalDriver failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }

    if (!request || (!isBillingAgreement && !request.amount)) {
        completionBlock(nil, [NSError errorWithDomain:BTPayPalDriverErrorDomain code:BTPayPalDriverErrorTypeInvalidRequest userInfo:nil]);
        return;
    }

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            if (completionBlock) {
                completionBlock(nil, error);
            }
            return;
        }

        if (![self verifyAppSwitchWithRemoteConfiguration:configuration.json error:&error]) {
            if (completionBlock) {
                completionBlock(nil, error);
            }
            return;
        }

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        NSMutableDictionary *experienceProfile = [NSMutableDictionary dictionary];

        if (!isBillingAgreement) {
            parameters[@"intent"] = [self.class intentTypeToString:request.intent];
            if (request.amount != nil) {
                parameters[@"amount"] = request.amount;
            }
        } else if (request.billingAgreementDescription.length > 0) {
            parameters[@"description"] = request.billingAgreementDescription;
        }

        parameters[@"offer_paypal_credit"] = @(request.offerCredit);

        experienceProfile[@"no_shipping"] = @(!request.isShippingAddressRequired);

        experienceProfile[@"brand_name"] = request.displayName ?: [configuration.json[@"paypal"][@"displayName"] asString];

        NSString *landingPageTypeValue = [self.class landingPageTypeToString:request.landingPageType];
        if (landingPageTypeValue != nil) {
            experienceProfile[@"landing_page_type"] = landingPageTypeValue;
        }

        if (request.localeCode != nil) {
            experienceProfile[@"locale_code"] = request.localeCode;
        }

        if (request.merchantAccountId != nil) {
            parameters[@"merchant_account_id"] = request.merchantAccountId;
        }

        // Currency code should only be used for Hermes Checkout (one-time payment).
        // For BA, currency should not be used.
        NSString *currencyCode = request.currencyCode ?: [configuration.json[@"paypal"][@"currencyIsoCode"] asString];
        if (!isBillingAgreement && currencyCode) {
            parameters[@"currency_iso_code"] = currencyCode;
        }

        if (request.shippingAddressOverride != nil) {
            experienceProfile[@"address_override"] = @(!request.isShippingAddressEditable);
            BTPostalAddress *shippingAddress = request.shippingAddressOverride;
            if (isBillingAgreement) {
                NSMutableDictionary *shippingAddressParams = [NSMutableDictionary dictionary];
                shippingAddressParams[@"line1"] = shippingAddress.streetAddress;
                shippingAddressParams[@"line2"] = shippingAddress.extendedAddress;
                shippingAddressParams[@"city"] = shippingAddress.locality;
                shippingAddressParams[@"state"] = shippingAddress.region;
                shippingAddressParams[@"postal_code"] = shippingAddress.postalCode;
                shippingAddressParams[@"country_code"] = shippingAddress.countryCodeAlpha2;
                shippingAddressParams[@"recipient_name"] = shippingAddress.recipientName;
                parameters[@"shipping_address"] = shippingAddressParams;
            } else {
                parameters[@"line1"] = shippingAddress.streetAddress;
                parameters[@"line2"] = shippingAddress.extendedAddress;
                parameters[@"city"] = shippingAddress.locality;
                parameters[@"state"] = shippingAddress.region;
                parameters[@"postal_code"] = shippingAddress.postalCode;
                parameters[@"country_code"] = shippingAddress.countryCodeAlpha2;
                parameters[@"recipient_name"] = shippingAddress.recipientName;
            }
        } else {
            experienceProfile[@"address_override"] = @NO;
        }

        if (request.lineItems.count > 0) {
            NSMutableArray *lineItemsArray = [NSMutableArray arrayWithCapacity:request.lineItems.count];
            for (BTPayPalLineItem *lineItem in request.lineItems) {
                [lineItemsArray addObject:[lineItem requestParameters]];
            }

            parameters[@"line_items"] = lineItemsArray;
        }

        NSString *returnURI;
        NSString *cancelURI;

        [self.class redirectURLsForCallbackURLScheme:self.returnURLScheme
                                       withReturnURL:&returnURI
                                       withCancelURL:&cancelURI];
        if (!returnURI || !cancelURI) {
            completionBlock(nil, [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                                     code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                                 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Application may not support One Touch callback URL scheme.",
                                                            NSLocalizedRecoverySuggestionErrorKey: @"Check the return URL scheme" }]);
            return;
        }

        if (returnURI) {
            parameters[@"return_url"] = returnURI;
        }
        if (cancelURI) {
            parameters[@"cancel_url"] = cancelURI;
        }

        parameters[@"experience_profile"] = experienceProfile;

        self.payPalRequest = request;

        NSString *url = isBillingAgreement ? @"setup_billing_agreement" : @"create_payment_resource";

        [self.apiClient POST:[NSString stringWithFormat:@"v1/paypal_hermes/%@", url]
                  parameters:parameters
                  completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
            if (error) {
                NSString *errorDetailsIssue = ((BTJSON *)error.userInfo[BTHTTPJSONResponseBodyKey][@"paymentResource"][@"errorDetails"][0][@"issue"]).asString;
                if (error.userInfo[NSLocalizedDescriptionKey] == nil && errorDetailsIssue != nil) {
                    NSMutableDictionary *dictionary = [error.userInfo mutableCopy];
                    dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue;
                    error = [NSError errorWithDomain:error.domain code:error.code userInfo:dictionary];
                }

                if (completionBlock) {
                    completionBlock(nil, error);
                }
                return;
            }

            NSURL *approvalUrl = [body[@"paymentResource"][@"redirectUrl"] asURL];
            if (approvalUrl == nil) {
                approvalUrl = [body[@"agreementSetup"][@"approvalUrl"] asURL];
            }
            self.approvalUrl = [self decorateApprovalURL:approvalUrl forRequest:request];

            NSString *pairingId = [self.class tokenFromApprovalURL:self.approvalUrl];

            self.clientMetadataId = [PPDataCollector generateClientMetadataID:pairingId
                                                                disableBeacon:NO
                                                                         data:nil];

            BOOL analyticsSuccess = error ? NO : YES;
            if (isBillingAgreement) {
                [self sendAnalyticsEventForInitiatingOneTouchForPaymentType:BTPayPalPaymentTypeBillingAgreement withSuccess:analyticsSuccess];
            } else {
                [self sendAnalyticsEventForInitiatingOneTouchForPaymentType:BTPayPalPaymentTypeCheckout withSuccess:analyticsSuccess];
            }

            [self handlePayPalRequestWithURL:approvalUrl
                                       error:error
                                 paymentType:isBillingAgreement ? BTPayPalPaymentTypeBillingAgreement : BTPayPalPaymentTypeCheckout
                                  completion:completionBlock];
        }];
    }];
}

- (NSDictionary *)dictionaryFromResponseURL:(NSURL *)url {
    if ([[self.class actionFromURLAction: url] isEqualToString:@"cancel"]) {
        return nil;
    }

    NSDictionary *resultDictionary = @{
        @"client": @{
                @"platform": @"iOS",
                @"product_name": @"PayPal",
                @"paypal_sdk_version": @"version"

        },
        @"response": @{
                @"webURL": url.absoluteString
        },
        @"response_type": @"web"
    };
    return resultDictionary;
}

- (void)handlePayPalRequestWithURL:(NSURL *)url
                             error:(NSError *)error
                       paymentType:(BTPayPalPaymentType)paymentType
                        completion:(void (^)(BTPayPalAccountNonce *, NSError *))completionBlock {
    if (!error) {
        // Defensive programming in case PayPal One Touch returns a non-HTTP URL so that SFAuthenticationSession doesn't crash
        if (![url.scheme.lowercaseString hasPrefix:@"http"]) {
            NSError *urlError = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                                    code:BTPayPalDriverErrorTypeUnknown
                                                userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Attempted to open an invalid URL in SFAuthenticationSession: %@://", url.scheme],
                                                            NSLocalizedRecoverySuggestionErrorKey: @"Try again or contact Braintree Support." }];

            NSString *eventName = [NSString stringWithFormat:@"ios.%@.webswitch.error.safariviewcontrollerbadscheme.%@", [self.class eventStringForPaymentType:paymentType], url.scheme];
            [self.apiClient sendAnalyticsEvent:eventName];

            if (completionBlock) {
                completionBlock(nil, urlError);
            }

            return;
        }

        [self performSwitchRequest:url paymentType:paymentType completion:completionBlock];

    } else if (completionBlock) {
        completionBlock(nil, error);
    }
}

- (void)performSwitchRequest:(NSURL *)appSwitchURL paymentType:(BTPayPalPaymentType)paymentType completion:(void (^)(BTPayPalAccountNonce *, NSError *))completionBlock {
    [self informDelegateAppContextWillSwitch];

    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:appSwitchURL resolvingAgainstBaseURL:NO];

    NSString *queryForAuthSession = [urlComponents.query stringByAppendingString:@"&bt_int_type=2"];
    urlComponents.query = queryForAuthSession;
    self.safariAuthenticationSession = [[SFAuthenticationSession alloc] initWithURL:urlComponents.URL
                                                                  callbackURLScheme:self.returnURLScheme
                                                                  completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        if (error) {
            if (error.domain == SFAuthenticationErrorDomain && error.code == SFAuthenticationErrorCanceledLogin) {
                if (self.becameActiveAfterSFAuthenticationSessionModal) {
                    [self.apiClient sendAnalyticsEvent:@"ios.sfauthsession.cancel.web"];
                } else {
                    [self.apiClient sendAnalyticsEvent:@"ios.sfauthsession.cancel.modal"];
                }
            }
            
            // User cancelled by breaking out of the PayPal browser switch flow
            // (e.g. "Cancel" button in SFAuthenticationSession)
            NSError *err = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                               code:BTPayPalDriverErrorTypeCanceled
                                           userInfo:@{NSLocalizedDescriptionKey: @"PayPal flow was canceled by the user."}];
            if (completionBlock) {
                completionBlock(nil, err);
            }
            return;
        }

        [self handleBrowserSwitchReturnURL:callbackURL
                               paymentType:paymentType
                                completion:completionBlock];
        self.safariAuthenticationSession = nil;
    }];

    if (self.safariAuthenticationSession != nil) {
        self.becameActiveAfterSFAuthenticationSessionModal = NO;
        self.isSFAuthenticationSessionStarted = [self.safariAuthenticationSession start];
        if (self.isSFAuthenticationSessionStarted) {
            [self.apiClient sendAnalyticsEvent:@"ios.sfauthsession.start.succeeded"];
        } else {
            [self.apiClient sendAnalyticsEvent:@"ios.sfauthsession.start.failed"];
        }
    }
}

- (NSString *)payPalEnvironmentForRemoteConfiguration:(BTJSON *)configuration {
    NSString *btPayPalEnvironmentName = [configuration[@"paypal"][@"environment"] asString];
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
    if ([[configuration[@"paypal"][@"environment"] asString] isEqualToString:@"offline"] && ![configuration[@"paypal"][@"clientId"] isString]) {
        return @"mock-paypal-client-id";
    } else {
        return [configuration[@"paypal"][@"clientId"] asString];
    }
}

- (BTClientMetadata *)clientMetadata {
    BTMutableClientMetadata *metadata = [self.apiClient.metadata mutableCopy];
    metadata.source = BTClientMetadataSourcePayPalBrowser;

    return [metadata copy];
}

+ (BTPostalAddress *)accountAddressFromJSON:(BTJSON *)addressJSON {
    if (!addressJSON.isObject) {
        return nil;
    }
    
    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.recipientName = [addressJSON[@"recipientName"] asString]; // Likely to be nil
    address.streetAddress = [addressJSON[@"street1"] asString];
    address.extendedAddress = [addressJSON[@"street2"] asString];
    address.locality = [addressJSON[@"city"] asString];
    address.region = [addressJSON[@"state"] asString];
    address.postalCode = [addressJSON[@"postalCode"] asString];
    address.countryCodeAlpha2 = [addressJSON[@"country"] asString];
    
    return address;
}

+ (BTPostalAddress *)shippingOrBillingAddressFromJSON:(BTJSON *)addressJSON {
    if (!addressJSON.isObject) {
        return nil;
    }
    
    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.recipientName = [addressJSON[@"recipientName"] asString]; // Likely to be nil
    address.streetAddress = [addressJSON[@"line1"] asString];
    address.extendedAddress = [addressJSON[@"line2"] asString];
    address.locality = [addressJSON[@"city"] asString];
    address.region = [addressJSON[@"state"] asString];
    address.postalCode = [addressJSON[@"postalCode"] asString];
    address.countryCodeAlpha2 = [addressJSON[@"countryCode"] asString];
    
    return address;
}

+ (BTPayPalCreditFinancingAmount *)creditFinancingAmountFromJSON:(BTJSON *)amountJSON {
    if (!amountJSON.isObject) {
        return nil;
    }

    NSString *currency = [amountJSON[@"currency"] asString];
    NSString *value = [amountJSON[@"value"] asString];

    return [[BTPayPalCreditFinancingAmount alloc] initWithCurrency:currency value:value];
}

+ (BTPayPalCreditFinancing *)creditFinancingFromJSON:(BTJSON *)creditFinancingOfferedJSON {
    if (!creditFinancingOfferedJSON.isObject) {
        return nil;
    }

    BOOL isCardAmountImmutable = [creditFinancingOfferedJSON[@"cardAmountImmutable"] isTrue];

    BTPayPalCreditFinancingAmount *monthlyPayment = [self.class creditFinancingAmountFromJSON:creditFinancingOfferedJSON[@"monthlyPayment"]];

    BOOL payerAcceptance = [creditFinancingOfferedJSON[@"payerAcceptance"] isTrue];
    NSInteger term = [creditFinancingOfferedJSON[@"term"] asIntegerOrZero];
    BTPayPalCreditFinancingAmount *totalCost = [self.class creditFinancingAmountFromJSON:creditFinancingOfferedJSON[@"totalCost"]];
    BTPayPalCreditFinancingAmount *totalInterest = [self.class creditFinancingAmountFromJSON:creditFinancingOfferedJSON[@"totalInterest"]];

    return [[BTPayPalCreditFinancing alloc] initWithCardAmountImmutable:isCardAmountImmutable
                                                         monthlyPayment:monthlyPayment
                                                        payerAcceptance:payerAcceptance
                                                                   term:term
                                                              totalCost:totalCost
                                                          totalInterest:totalInterest];
}

+ (BTPayPalAccountNonce *)payPalAccountFromJSON:(BTJSON *)payPalAccount {
    NSString *nonce = [payPalAccount[@"nonce"] asString];
    
    BTJSON *details = payPalAccount[@"details"];
    
    NSString *email = [details[@"email"] asString];
    NSString *clientMetadataId = [details[@"correlationId"] asString];
    // Allow email to be under payerInfo
    if ([details[@"payerInfo"][@"email"] isString]) {
        email = [details[@"payerInfo"][@"email"] asString];
    }
    
    NSString *firstName = [details[@"payerInfo"][@"firstName"] asString];
    NSString *lastName = [details[@"payerInfo"][@"lastName"] asString];
    NSString *phone = [details[@"payerInfo"][@"phone"] asString];
    NSString *payerId = [details[@"payerInfo"][@"payerId"] asString];
    BOOL isDefault = [payPalAccount[@"default"] isTrue];
    
    BTPostalAddress *shippingAddress = [self.class shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"shippingAddress"]];
    BTPostalAddress *billingAddress = [self.class shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"billingAddress"]];
    if (!shippingAddress) {
        shippingAddress = [self.class accountAddressFromJSON:details[@"payerInfo"][@"accountAddress"]];
    }

    BTPayPalCreditFinancing *creditFinancing =  [self.class creditFinancingFromJSON:details[@"creditFinancingOffered"]];

    BTPayPalAccountNonce *tokenizedPayPalAccount = [[BTPayPalAccountNonce alloc] initWithNonce:nonce
                                                                                         email:email
                                                                                     firstName:firstName
                                                                                      lastName:lastName
                                                                                         phone:phone
                                                                                billingAddress:billingAddress
                                                                               shippingAddress:shippingAddress
                                                                              clientMetadataId:clientMetadataId
                                                                                       payerId:payerId
                                                                                     isDefault:isDefault
                                                                               creditFinancing:creditFinancing];
    
    return tokenizedPayPalAccount;
}

+ (NSString *)intentTypeToString:(BTPayPalRequestIntent)intentType {
    NSString *result = nil;

    switch(intentType) {
        case BTPayPalRequestIntentAuthorize:
            result = @"authorize";
            break;
        case BTPayPalRequestIntentSale:
            result = @"sale";
            break;
        case BTPayPalRequestIntentOrder:
            result = @"order";
            break;
        default:
            result = @"authorize";
            break;
    }

    return result;
}

+ (NSString *)landingPageTypeToString:(BTPayPalRequestLandingPageType)landingPageType {
    switch(landingPageType) {
        case BTPayPalRequestLandingPageTypeLogin:
            return @"login";
        case BTPayPalRequestLandingPageTypeBilling:
            return @"billing";
        default:
            return nil;
    }
}

#pragma mark - App Switch Delegate Informers

- (void)informDelegateAppContextWillSwitch {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppContextWillSwitchNotification
                                                                 object:self
                                                               userInfo:nil];
    [NSNotificationCenter.defaultCenter postNotification:notification];

    if ([self.appSwitchDelegate respondsToSelector:@selector(appContextWillSwitch:)]) {
        [self.appSwitchDelegate appContextWillSwitch:self];
    }
}

- (void)informDelegateAppContextDidReturn {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppContextDidReturnNotification
                                                                 object:self
                                                               userInfo:nil];
    [NSNotificationCenter.defaultCenter postNotification:notification];

    if ([self.appSwitchDelegate respondsToSelector:@selector(appContextDidReturn:)]) {
        [self.appSwitchDelegate appContextDidReturn:self];
    }
}

#pragma mark - Preflight check

- (BOOL)verifyAppSwitchWithRemoteConfiguration:(BTJSON *)configuration error:(NSError * __autoreleasing *)error {
    if (![configuration[@"paypalEnabled"] isTrue]) {
        [self.apiClient sendAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal is not enabled for this merchant",
                                                 NSLocalizedRecoverySuggestionErrorKey: @"Enable PayPal for this merchant in the Braintree Control Panel" }];
        }
        return NO;
    }

    if (self.returnURLScheme == nil || [self.returnURLScheme isEqualToString:@""]) {
        NSString *recoverySuggestion = @"PayPal requires a return URL scheme to be configured via [BTAppSwitch setReturnURLScheme:]. This custom URL scheme must also be registered with your app.";
        [[BTLogger sharedLogger] critical:recoverySuggestion];

        [self.apiClient sendAnalyticsEvent:@"ios.paypal-otc.preflight.nil-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: @"Missing returnURLScheme",
                                                 NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion }];
        }

        return NO;
    }

    if (![self.class doesApplicationSupportOneTouchCallbackURLScheme:self.returnURLScheme]) {
        NSString *recoverySuggestion = [NSString stringWithFormat:@"PayPal requires [BTAppSwitch setReturnURLScheme:] to be configured to begin with your app's bundle ID (%@). Currently, it is set to (%@).", NSBundle.mainBundle.bundleIdentifier, self.returnURLScheme];
        [[BTLogger sharedLogger] critical:recoverySuggestion];

        [self.apiClient sendAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                         code:BTPayPalDriverErrorTypeIntegrationReturnURLScheme
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: @"Application does not support One Touch callback URL scheme",
                                                NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion }];
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
        case BTPayPalPaymentTypeCheckout:
            return @"paypal-single-payment";
        default:
            return nil;
    }
}

- (void)sendAnalyticsEventForInitiatingOneTouchForPaymentType:(BTPayPalPaymentType)paymentType
                                                  withSuccess:(BOOL)success {
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.webswitch.initiate.%@", [self.class eventStringForPaymentType:paymentType], success ? @"started" : @"failed"];
    [self.apiClient sendAnalyticsEvent:eventName];

    if ((paymentType == BTPayPalPaymentTypeCheckout || paymentType == BTPayPalPaymentTypeBillingAgreement) && self.payPalRequest.offerCredit) {
        NSString *eventName = [NSString stringWithFormat:@"ios.%@.webswitch.credit.offered.%@", [self.class eventStringForPaymentType:paymentType], success ? @"started" : @"failed"];

        [self.apiClient sendAnalyticsEvent:eventName];
    }
}

- (void)sendAnalyticsEventIfCreditFinancingInNonce:(BTPayPalAccountNonce *)payPalAccountNonce forPaymentType:(BTPayPalPaymentType)paymentType {
    if (payPalAccountNonce.creditFinancing) {
        NSString *eventName = [NSString stringWithFormat:@"ios.%@.credit.accepted", [self.class eventStringForPaymentType:paymentType]];

        [self.apiClient sendAnalyticsEvent:eventName];
    }
}

- (void)sendAnalyticsEventForTokenizationSuccessForPaymentType:(BTPayPalPaymentType)paymentType {
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.tokenize.succeeded", [self.class eventStringForPaymentType:paymentType]];
    [self.apiClient sendAnalyticsEvent:eventName];
}

- (void)sendAnalyticsEventForTokenizationFailureForPaymentType:(BTPayPalPaymentType)paymentType {
    NSString *eventName = [NSString stringWithFormat:@"ios.%@.tokenize.failed", [self.class eventStringForPaymentType:paymentType]];
    [self.apiClient sendAnalyticsEvent:eventName];
}

- (NSString *)returnURLScheme {
    if (!_returnURLScheme) {
        _returnURLScheme = [[BTAppSwitch sharedInstance] returnURLScheme];
    }
    return _returnURLScheme;
}

#pragma mark - Internal

- (NSURL *)decorateApprovalURL:(NSURL*)approvalURL forRequest:(BTPayPalRequest *)paypalRequest {
    if (approvalURL != nil && paypalRequest.userAction != BTPayPalRequestUserActionDefault) {
        NSURLComponents* approvalURLComponents = [[NSURLComponents alloc] initWithURL:approvalURL resolvingAgainstBaseURL:NO];
        if (approvalURLComponents != nil) {
            NSString *userActionValue = [BTPayPalDriver userActionTypeToString:paypalRequest.userAction];
            if ([userActionValue length] > 0) {
                NSString *query = [approvalURLComponents query];
                NSString *delimiter = [query length] == 0 ? @"" : @"&";
                query = [NSString stringWithFormat:@"%@%@useraction=%@", query, delimiter, userActionValue];
                approvalURLComponents.query = query;
            }
            return [approvalURLComponents URL];
        }
    }
    return approvalURL;
}

#pragma mark - Browser Switch handling

- (void)handleBrowserSwitchReturnURL:(NSURL *)url
                         paymentType:(BTPayPalPaymentType)paymentType
                          completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
    [self informDelegateAppContextDidReturn];

    if (![self.class isValidURLAction: url]) {
        NSError *responseError = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                                     code:BTPayPalDriverErrorTypeUnknown
                                                 userInfo:@{ NSLocalizedDescriptionKey: @"Unexpected response" }];

        if (completionBlock) {
            completionBlock(nil, responseError);
        }
        return;
    }

    NSDictionary *response = [self dictionaryFromResponseURL:url];

    if (!response) {
        if (completionBlock) {
            // If there's no response, the user canceled out of the flow using the cancel link
            // on the PayPal website
            NSError *err = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                               code:BTPayPalDriverErrorTypeCanceled
                                           userInfo:@{NSLocalizedDescriptionKey: @"PayPal flow was canceled by the user."}];

            completionBlock(nil, err);
        }
        return;
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"paypal_account"] = [response mutableCopy];

    if (paymentType == BTPayPalPaymentTypeCheckout) {
        parameters[@"paypal_account"][@"options"] = @{ @"validate": @NO };
        if (self.payPalRequest) {
            parameters[@"paypal_account"][@"intent"] = [self.class intentTypeToString:self.payPalRequest.intent];
        }
    }
    if (self.clientMetadataId) {
        parameters[@"paypal_account"][@"correlation_id"] = self.clientMetadataId;
    }

    if (self.payPalRequest != nil && self.payPalRequest.merchantAccountId != nil) {
        parameters[@"merchant_account_id"] = self.payPalRequest.merchantAccountId;
    }

    BTClientMetadata *metadata = [self clientMetadata];
    parameters[@"_meta"] = @{
        @"source" : metadata.sourceString,
        @"integration" : metadata.integrationString,
        @"sessionId" : metadata.sessionId,
    };

    [self.apiClient POST:@"/v1/payment_methods/paypal_accounts"
              parameters:parameters
              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            [self sendAnalyticsEventForTokenizationFailureForPaymentType:paymentType];
            if (completionBlock) {
                completionBlock(nil, error);
            }
            return;
        }

        [self sendAnalyticsEventForTokenizationSuccessForPaymentType:paymentType];

        BTJSON *payPalAccount = body[@"paypalAccounts"][0];
        BTPayPalAccountNonce *tokenizedAccount = [self.class payPalAccountFromJSON:payPalAccount];

        [self sendAnalyticsEventIfCreditFinancingInNonce:tokenizedAccount forPaymentType:paymentType];

        if (completionBlock) {
            completionBlock(tokenizedAccount, nil);
        }
    }];
}

+ (BOOL)doesApplicationSupportOneTouchCallbackURLScheme:(NSString *)callbackURLScheme {
    BOOL doesSupport = NO;
    // checks the callbackURLScheme is present and app responds to it.
    doesSupport = [self isCallbackURLSchemeValid:callbackURLScheme];
    return doesSupport;
}

#pragma mark - Class Methods

+ (NSString *)userActionTypeToString:(BTPayPalRequestUserAction)userActionType {
    NSString *result = nil;

    switch(userActionType) {
        case BTPayPalRequestUserActionCommit:
            result = @"commit";
            break;
        default:
            result = @"";
            break;
    }

    return result;
}

+ (NSString *)tokenFromApprovalURL:(NSURL *)approvalURL {
    NSDictionary *queryDictionary = [self parseQueryString:[approvalURL query]];
    return queryDictionary[@"token"] ?: queryDictionary[@"ba_token"];
}

+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if (elements.count > 1) {
            NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
            if (key.length && val.length) {
                dict[key] = val;
            }
        }
    }
    return dict;
}

+ (void)redirectURLsForCallbackURLScheme:(NSString *)callbackURLScheme
                           withReturnURL:(NSString * __autoreleasing *)returnURL
                           withCancelURL:(NSString * __autoreleasing *)cancelURL {
    *returnURL = nil;
    *cancelURL = nil;

    if ([self isCallbackURLSchemeValid:callbackURLScheme]) {
        *returnURL = [NSString stringWithFormat:@"%@://%@%@", callbackURLScheme, BTRedirectURLHostAndPath, @"success"];
        *cancelURL = [NSString stringWithFormat:@"%@://%@%@", callbackURLScheme, BTRedirectURLHostAndPath, @"cancel"];
    }
}

+ (BOOL)isValidURLAction:(NSURL *)url {
    NSString *scheme = url.scheme;
    if (!scheme.length) {
        return NO;
    }

    NSString *hostAndPath = [url.host stringByAppendingString:url.path];
    NSMutableArray *pathComponents = [[hostAndPath componentsSeparatedByString:@"/"] mutableCopy];
    [pathComponents removeLastObject]; // remove the action (`success`, `cancel`, etc)
    hostAndPath = [pathComponents componentsJoinedByString:@"/"];
    if ([hostAndPath length]) {
        hostAndPath = [hostAndPath stringByAppendingString:@"/"];
    }
    if (![hostAndPath isEqualToString:BTRedirectURLHostAndPath]) {
        return NO;
    }

    NSString *action = [self actionFromURLAction:url];
    if (!action.length) {
        return NO;
    }

    NSArray *validActions = @[@"success", @"cancel", @"authenticate"];
    if (![validActions containsObject:action]) {
        return NO;
    }

    NSString *query = [url query];
    if (!query.length) {
        // should always have at least a payload or else a Hermes token (even if the action is "cancel")
        return NO;
    }

    return YES;
}

+ (NSString *)actionFromURLAction:(NSURL *)url {
    NSString *action = [url.lastPathComponent componentsSeparatedByString:@"?"][0];
    if (![action length]) {
        action = url.host;
    }
    return action;
}

+ (BOOL)isCallbackURLSchemeValid:(NSString *)callbackURLScheme {
    NSString *bundleID = [[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"] lowercaseString];

    if ([bundleID isEqualToString:@"com.apple.dt.xctest.tool"]) {
        return YES;
    }

    // There are issues returning to the app if the return URL begins with a `-`
    // Allow callback URLs that remove the leading `-`
    // Ex: An app with Bundle ID `-com.example.myapp` can use the callback URL `com.example.myapp.payments`
    if (bundleID.length <= 1) {
        return NO;
    } else if ([[bundleID substringToIndex:1] isEqualToString:@"-"] && ![[callbackURLScheme lowercaseString] hasPrefix:bundleID]) {
        bundleID = [bundleID substringFromIndex:1];
    }

    if (bundleID && ![[callbackURLScheme lowercaseString] hasPrefix:bundleID]) {
        return NO;
    }

    // check the actual plist that the app is fully configured rather than just making canOpenURL call
    NSArray *urlTypes = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for (NSDictionary *item in urlTypes) {
        NSArray *bundleURLSchemes = item[@"CFBundleURLSchemes"];
        if (NSNotFound != [bundleURLSchemes indexOfObject:callbackURLScheme]) {
            return YES;
        }
    }

    return NO;
}

@end
