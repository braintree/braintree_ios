#import "BTPayPalDriver_Internal.h"
#import "BTPayPalAccountNonce_Internal.h"
#import "BTPayPalCreditFinancing_Internal.h"
#import "BTPayPalCreditFinancingAmount_Internal.h"
#import "BTPayPalRequest_Internal.h"
#import "BTPayPalCheckoutRequest_Internal.h"

#if __has_include(<Braintree/BraintreePayPal.h>) // CocoaPods
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTAPIClient_Internal.h>
#import <Braintree/BTPaymentMethodNonceParser.h>
#import <Braintree/BTLogger_Internal.h>
#import <Braintree/BTConfiguration+PayPal.h>
#import <Braintree/BTPayPalLineItem.h>

#elif SWIFT_PACKAGE                              // SPM
#import <BraintreeCore/BraintreeCore.h>
#import "../BraintreeCore/BTAPIClient_Internal.h"
#import "../BraintreeCore/BTPaymentMethodNonceParser.h"
#import "../BraintreeCore/BTLogger_Internal.h"
#import <BraintreePayPal/BTConfiguration+PayPal.h>
#import <BraintreePayPal/BTPayPalLineItem.h>

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTPaymentMethodNonceParser.h>
#import <BraintreeCore/BTLogger_Internal.h>
#import <BraintreePayPal/BTConfiguration+PayPal.h>
#import <BraintreePayPal/BTPayPalLineItem.h>
#endif

#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import PayPalDataCollector;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <PayPalDataCollector/PayPalDataCollector-Swift.h>
#endif

NSString *const BTPayPalDriverErrorDomain = @"com.braintreepayments.BTPayPalDriverErrorDomain";

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

@interface BTPayPalDriver () <ASWebAuthenticationPresentationContextProviding>

@property (nonatomic, assign) BOOL returnedToAppAfterPermissionAlert;

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
    if (self.isAuthenticationSessionStarted) {
        self.returnedToAppAfterPermissionAlert = YES;
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Billing Agreement (Vault)

- (void)requestBillingAgreement:(BTPayPalVaultRequest *)request
                     completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
    [self tokenizePayPalAccountWithPayPalRequest:request completion:completionBlock];
}

#pragma mark - One-Time Payment (Checkout)

- (void)requestOneTimePayment:(BTPayPalCheckoutRequest *)request
                   completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
    [self tokenizePayPalAccountWithPayPalRequest:request completion:completionBlock];
}

#pragma mark - Helpers

- (void)tokenizePayPalAccountWithPayPalRequest:(BTPayPalRequest *)request completion:(void (^)(BTPayPalAccountNonce *, NSError *))completionBlock {
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                             code:BTPayPalDriverErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTPayPalDriver failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }

    if (!request) {
        completionBlock(nil, [NSError errorWithDomain:BTPayPalDriverErrorDomain code:BTPayPalDriverErrorTypeInvalidRequest userInfo:nil]);
        return;
    }

    if (!([request isKindOfClass:BTPayPalCheckoutRequest.class] || [request isKindOfClass:BTPayPalVaultRequest.class])) {
        NSError *error = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                             code:BTPayPalDriverErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTPayPalDriver failed because request is not of type BTPayPalCheckoutRequest or BTPayPalVaultRequest."}];
        completionBlock(nil, error);
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

        self.payPalRequest = request;

        [self.apiClient POST:request.hermesPath
                  parameters:[request parametersWithConfiguration:configuration]
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
            approvalUrl = [self decorateApprovalURL:approvalUrl forRequest:request];

            NSString *pairingID = [self.class tokenFromApprovalURL:approvalUrl];

            self.clientMetadataID = [PPDataCollector clientMetadataID:pairingID];

            BOOL analyticsSuccess = error ? NO : YES;

            [self sendAnalyticsEventForInitiatingOneTouchForPaymentType:request.paymentType withSuccess:analyticsSuccess];

            [self handlePayPalRequestWithURL:approvalUrl
                                       error:error
                                 paymentType:request.paymentType
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
        // Defensive programming in case PayPal One Touch returns a non-HTTP URL so that ASWebAuthenticationSession doesn't crash
        if (![url.scheme.lowercaseString hasPrefix:@"http"]) {
            NSError *urlError = [NSError errorWithDomain:BTPayPalDriverErrorDomain
                                                    code:BTPayPalDriverErrorTypeUnknown
                                                userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Attempted to open an invalid URL in ASWebAuthenticationSession: %@://", url.scheme],
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
    self.approvalUrl = appSwitchURL; // exposed for testing
    self.authenticationSession = [[ASWebAuthenticationSession alloc] initWithURL:appSwitchURL
                                                               callbackURLScheme:BTPayPalCallbackURLScheme
                                                               completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        // Required to avoid memory leak for BTPayPalDriver
        self.authenticationSession = nil;

        if (error) {
            if (error.domain == ASWebAuthenticationSessionErrorDomain && error.code == ASWebAuthenticationSessionErrorCodeCanceledLogin) {
                if (self.returnedToAppAfterPermissionAlert) {
                    // User tapped system cancel button in browser
                    NSString *eventName = [NSString stringWithFormat:@"ios.%@.authsession.browser.cancel", [self.class eventStringForPaymentType:paymentType]];
                    [self.apiClient sendAnalyticsEvent:eventName];
                } else {
                    // User tapped system cancel button on permission alert
                    NSString *eventName = [NSString stringWithFormat:@"ios.%@.authsession.alert.cancel", [self.class eventStringForPaymentType:paymentType]];
                    [self.apiClient sendAnalyticsEvent:eventName];
                }
            }

            // User canceled by breaking out of the PayPal browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
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
    }];

    if (@available(iOS 13, *)) {
        self.authenticationSession.presentationContextProvider = self;
    }

    self.returnedToAppAfterPermissionAlert = NO;
    self.isAuthenticationSessionStarted = [self.authenticationSession start];
    if (self.isAuthenticationSessionStarted) {
        NSString *eventName = [NSString stringWithFormat:@"ios.%@.authsession.start.succeeded", [self.class eventStringForPaymentType:paymentType]];
        [self.apiClient sendAnalyticsEvent:eventName];
    } else {
        NSString *eventName = [NSString stringWithFormat:@"ios.%@.authsession.start.failed", [self.class eventStringForPaymentType:paymentType]];
        [self.apiClient sendAnalyticsEvent:eventName];
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
    NSString *clientMetadataID = [details[@"correlationId"] asString];
    // Allow email to be under payerInfo
    if ([details[@"payerInfo"][@"email"] isString]) {
        email = [details[@"payerInfo"][@"email"] asString];
    }
    
    NSString *firstName = [details[@"payerInfo"][@"firstName"] asString];
    NSString *lastName = [details[@"payerInfo"][@"lastName"] asString];
    NSString *phone = [details[@"payerInfo"][@"phone"] asString];
    NSString *payerID = [details[@"payerInfo"][@"payerId"] asString];
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
                                                                              clientMetadataID:clientMetadataID
                                                                                       payerID:payerID
                                                                                     isDefault:isDefault
                                                                               creditFinancing:creditFinancing];
    
    return tokenizedPayPalAccount;
}

#pragma mark - ASWebAuthenticationPresentationContextProviding protocol

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session API_AVAILABLE(ios(13)) {
    if (self.payPalRequest.activeWindow) {
        return self.payPalRequest.activeWindow;
    }

    for (UIScene* scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            return windowScene.windows.firstObject;
        }
    }
    return UIApplication.sharedApplication.windows.firstObject;
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

    return YES;
}

#pragma mark - Analytics Helpers

+ (NSString *)eventStringForPaymentType:(BTPayPalPaymentType)paymentType {
    switch (paymentType) {
        case BTPayPalPaymentTypeVault:
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

    if ([self.payPalRequest isKindOfClass:BTPayPalCheckoutRequest.class] && ((BTPayPalCheckoutRequest *)self.payPalRequest).offerPayLater) {
        NSString *eventName = [NSString stringWithFormat:@"ios.%@.webswitch.paylater.offered.%@", [self.class eventStringForPaymentType:paymentType], success ? @"started" : @"failed"];

        [self.apiClient sendAnalyticsEvent:eventName];
    }

    if ([self.payPalRequest isKindOfClass:BTPayPalVaultRequest.class] && ((BTPayPalVaultRequest *)self.payPalRequest).offerCredit) {
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

#pragma mark - Internal

- (NSURL *)decorateApprovalURL:(NSURL*)approvalURL forRequest:(BTPayPalRequest *)paypalRequest {
    if (approvalURL != nil && [paypalRequest isKindOfClass:BTPayPalCheckoutRequest.class]) {
        NSURLComponents* approvalURLComponents = [[NSURLComponents alloc] initWithURL:approvalURL resolvingAgainstBaseURL:NO];
        if (approvalURLComponents != nil) {
            NSString *userActionValue = ((BTPayPalCheckoutRequest *)paypalRequest).userActionAsString;
            if (userActionValue.length > 0) {
                NSURLQueryItem *userActionQueryItem = [[NSURLQueryItem alloc] initWithName:@"useraction" value:userActionValue];
                NSArray<NSURLQueryItem *> *queryItems = approvalURLComponents.queryItems ?: @[];
                approvalURLComponents.queryItems = [queryItems arrayByAddingObject:userActionQueryItem];
            }
            return approvalURLComponents.URL;
        }
    }
    return approvalURL;
}

#pragma mark - Browser Switch handling

- (void)handleBrowserSwitchReturnURL:(NSURL *)url
                         paymentType:(BTPayPalPaymentType)paymentType
                          completion:(void (^)(BTPayPalAccountNonce *tokenizedCheckout, NSError *error))completionBlock {
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
        if ([self.payPalRequest isKindOfClass:BTPayPalCheckoutRequest.class] && ((BTPayPalCheckoutRequest *) self.payPalRequest).intentAsString) {
            parameters[@"paypal_account"][@"intent"] = ((BTPayPalCheckoutRequest *) self.payPalRequest).intentAsString;
        }
    }

    if (self.clientMetadataID) {
        parameters[@"paypal_account"][@"correlation_id"] = self.clientMetadataID;
    }

    if (self.payPalRequest != nil && self.payPalRequest.merchantAccountID != nil) {
        parameters[@"merchant_account_id"] = self.payPalRequest.merchantAccountID;
    }

    BTClientMetadata *metadata = [self clientMetadata];
    parameters[@"_meta"] = @{
        @"source" : metadata.sourceString,
        @"integration" : metadata.integrationString,
        @"sessionId" : metadata.sessionID,
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

#pragma mark - Class Methods

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
    if (![hostAndPath isEqualToString:BTPayPalCallbackURLHostAndPath]) {
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

@end
