#import "BTPaymentFlowClient_Internal.h"
#import "BTPaymentFlowClient+LocalPayment_Internal.h"
#import <SafariServices/SafariServices.h>

//Objective-C Module imports
#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTLocalPaymentRequest.h>
#import <Braintree/BTConfiguration+LocalPayment.h>
#import <Braintree/BTLocalPaymentResult.h>
#import <Braintree/BraintreeCore-Swift.h>

#elif SWIFT_PACKAGE                                   // SPM
#import <BraintreePaymentFlow/BTLocalPaymentRequest.h>
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#import <BraintreeCore/BraintreeCore-Swift.h>

#else                                                 // Carthage and Local Builds
#import <BraintreePaymentFlow/BTLocalPaymentRequest.h>
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif


//Swift Module imports
#if __has_include(<Braintree/Braintree-Swift.h>)      // CocoaPods-generated Swift Header
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                                   // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeDataCollector;
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")              // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                                 // Carthage and Local Builds
#import <BraintreeDataCollector/BraintreeDataCollector-Swift.h>
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif


@interface BTLocalPaymentRequest ()

@property (nonatomic, copy, nullable) NSString *paymentID;
@property (nonatomic, weak) id<BTPaymentFlowClientDelegate> paymentFlowClientDelegate;
@property (nonatomic, strong) NSString *correlationID;

@end

@implementation BTLocalPaymentRequest

- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentClientDelegate:(id<BTPaymentFlowClientDelegate>)delegate {
    self.paymentFlowClientDelegate = delegate;
    BTLocalPaymentRequest *localPaymentRequest = (BTLocalPaymentRequest *)request;
    [apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, NSError *configurationError) {
        if (configurationError) {
            [delegate onPaymentComplete:nil error:configurationError];
            return;
        }
        
        BTDataCollector *dataCollector = [[BTDataCollector alloc] initWithAPIClient:apiClient];
        self.correlationID = [dataCollector clientMetadataID:nil];

        NSError *integrationError;

        if ([self.paymentFlowClientDelegate returnURLScheme] == nil || [[self.paymentFlowClientDelegate returnURLScheme] isEqualToString:@""]) {
            NSLog(@"%@ Local Payment requires a return URL scheme to be configured via [BTAppContextSwitcher setReturnURLScheme:]", [BTLogLevelDescription stringFor:BTLogLevelCritical]);
            integrationError = [NSError errorWithDomain:BTPaymentFlowErrorDomain
                                                 code:BTPaymentFlowErrorTypeInvalidReturnURL
                                             userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app or browser switch."}];
        } else if (![configuration isLocalPaymentEnabled]) {
            NSLog(@"%@ Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments.", [BTLogLevelDescription stringFor:BTLogLevelCritical]);
            integrationError = [NSError errorWithDomain:BTPaymentFlowErrorDomain
                                                 code:BTPaymentFlowErrorTypeDisabled
                                             userInfo:@{NSLocalizedDescriptionKey: @"Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments."}];
        } else if (localPaymentRequest.localPaymentFlowDelegate == nil) {
            NSLog(@"%@ BTLocalPaymentRequest localPaymentFlowDelegate can not be nil.", [BTLogLevelDescription stringFor:BTLogLevelCritical]);
            integrationError = [NSError errorWithDomain:BTPaymentFlowErrorDomain
                                                 code:BTPaymentFlowErrorTypeIntegration
                                             userInfo:@{NSLocalizedDescriptionKey: @"Failed to begin payment flow: BTLocalPaymentRequest localPaymentFlowDelegate can not be nil."}];
        } else if (localPaymentRequest.amount == nil || localPaymentRequest.paymentType == nil) {
            NSLog(@"%@ BTLocalPaymentRequest amount and paymentType can not be nil.", [BTLogLevelDescription stringFor:BTLogLevelCritical]);
            integrationError = [NSError errorWithDomain:BTPaymentFlowErrorDomain
                                                 code:BTPaymentFlowErrorTypeIntegration
                                             userInfo:@{NSLocalizedDescriptionKey: @"Failed to begin payment flow: BTLocalPaymentRequest amount and paymentType can not be nil."}];
        }
        
        if (integrationError != nil) {
            [delegate onPaymentComplete:nil error:integrationError];
            return;
        }

        NSMutableDictionary *params = [@{
                                 @"amount": localPaymentRequest.amount,
                                 @"funding_source": localPaymentRequest.paymentType,
                                 @"intent": @"sale"
                                 } mutableCopy];

        params[@"return_url"] = [NSString stringWithFormat:@"%@%@", [delegate returnURLScheme], @"://x-callback-url/braintree/local-payment/success"];
        params[@"cancel_url"] = [NSString stringWithFormat:@"%@%@", [delegate returnURLScheme], @"://x-callback-url/braintree/local-payment/cancel"];

        if (localPaymentRequest.paymentTypeCountryCode) {
            params[@"payment_type_country_code"] = localPaymentRequest.paymentTypeCountryCode;
        }

        if (localPaymentRequest.address) {
            params[@"line1"] = localPaymentRequest.address.streetAddress;
            params[@"line2"] = localPaymentRequest.address.extendedAddress;
            params[@"city"] = localPaymentRequest.address.locality;
            params[@"state"] = localPaymentRequest.address.region;
            params[@"postal_code"] = localPaymentRequest.address.postalCode;
            params[@"country_code"] = localPaymentRequest.address.countryCodeAlpha2;
        }

        if (localPaymentRequest.currencyCode) {
            params[@"currency_iso_code"] = localPaymentRequest.currencyCode;
        }

        if (localPaymentRequest.givenName) {
            params[@"first_name"] = localPaymentRequest.givenName;
        }

        if (localPaymentRequest.surname) {
            params[@"last_name"] = localPaymentRequest.surname;
        }

        if (localPaymentRequest.email) {
            params[@"payer_email"] = localPaymentRequest.email;
        }

        if (localPaymentRequest.phone) {
            params[@"phone"] = localPaymentRequest.phone;
        }

        if (localPaymentRequest.merchantAccountID) {
            params[@"merchant_account_id"] = localPaymentRequest.merchantAccountID;
        }

        if (localPaymentRequest.bic) {
            params[@"bic"] = localPaymentRequest.bic;
        }

        NSMutableDictionary *experienceProfile = [@{
            @"no_shipping": @(!localPaymentRequest.isShippingAddressRequired)
        } mutableCopy];

        if (localPaymentRequest.displayName) {
            experienceProfile[@"brand_name"] = localPaymentRequest.displayName;
        }
        
        params[@"experience_profile"] = [experienceProfile copy];

        [apiClient POST:@"v1/local_payments/create"
                   parameters:params
                   completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
             if (!error) {
                 self.paymentID = [body[@"paymentResource"][@"paymentToken"] asString];
                 NSString *approvalUrl = [body[@"paymentResource"][@"redirectUrl"] asString];
                 NSURL *url = [NSURL URLWithString:approvalUrl];

                 if (self.paymentID && url) {
                     [self.localPaymentFlowDelegate localPaymentStarted:self paymentID:self.paymentID start:^{
                         [delegate onPaymentWithURL:url error:error];
                     }];
                 } else {
                     NSLog(@"%@ Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists.", [BTLogLevelDescription stringFor:BTLogLevelCritical]);
                     NSError *error = [NSError errorWithDomain:BTPaymentFlowErrorDomain
                                                          code:BTPaymentFlowErrorTypeAppSwitchFailed
                                                      userInfo:@{NSLocalizedDescriptionKey: @"Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists."}];
                     [delegate onPaymentComplete:nil error:error];
                     return;
                 }
             } else {
                 if (error.code == BTCoreConstants.networkConnectionLostCode) {
                     [apiClient sendAnalyticsEvent:@"ios.local-payment-methods.network-connection.failure"];
                 }

                 [delegate onPaymentWithURL:nil error:error];
             }
         }];
    }];
}

- (void)handleOpenURL:(__unused NSURL *)url {
    if ([url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/local-payment/cancel"]) {
        // canceled
        NSError *error = [NSError errorWithDomain:BTPaymentFlowErrorDomain
                                             code:BTPaymentFlowErrorTypeCanceled
                                         userInfo:@{}];
        [self.paymentFlowClientDelegate onPaymentComplete:nil error:error];
    } else {
        // success
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"paypal_account"] = [@{} mutableCopy];
        parameters[@"paypal_account"][@"response"] = @{ @"webURL": url.absoluteString };
        parameters[@"paypal_account"][@"response_type"] = @"web";
        parameters[@"paypal_account"][@"options"] = @{ @"validate": @NO };
        parameters[@"paypal_account"][@"intent"] = @"sale";

        if (self.correlationID) {
            parameters[@"paypal_account"][@"correlation_id"] = self.correlationID;
        }

        if (self.merchantAccountID) {
            parameters[@"merchant_account_id"] = self.merchantAccountID;
        }

        BTClientMetadata *metadata =  self.paymentFlowClientDelegate.apiClient.metadata;
        parameters[@"_meta"] = @{
                                 @"source" : metadata.sourceString,
                                 @"integration" : metadata.integrationString,
                                 @"sessionId" : metadata.sessionID,
                                 };

        [self.paymentFlowClientDelegate.apiClient POST:@"/v1/payment_methods/paypal_accounts"
                  parameters:parameters
                  completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
         {
             if (error) {
                 if (error.code == BTCoreConstants.networkConnectionLostCode) {
                     [self.paymentFlowClientDelegate.apiClient sendAnalyticsEvent:@"ios.local-payment-methods.network-connection.failure"];
                 }
                 [self.paymentFlowClientDelegate onPaymentComplete:nil error:error];
                 return;
             } else {
                 BTJSON *payPalAccount = body[@"paypalAccounts"][0];
                 NSString *nonce = [payPalAccount[@"nonce"] asString];
                 NSString *type = [payPalAccount[@"type"] asString];

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

                 BTPostalAddress *shippingAddress = [self.class shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"shippingAddress"]];
                 BTPostalAddress *billingAddress = [self.class shippingOrBillingAddressFromJSON:details[@"payerInfo"][@"billingAddress"]];
                 if (!shippingAddress) {
                     shippingAddress = [self.class accountAddressFromJSON:details[@"payerInfo"][@"accountAddress"]];
                 }

                 BTLocalPaymentResult *tokenizedLocalPayment = [[BTLocalPaymentResult alloc] initWithNonce:nonce
                                                                                                      type:type
                                                                                                      email:email
                                                                                                  firstName:firstName
                                                                                                   lastName:lastName
                                                                                                      phone:phone
                                                                                             billingAddress:billingAddress
                                                                                            shippingAddress:shippingAddress
                                                                                           clientMetadataID:clientMetadataID
                                                                                                    payerID:payerID];
                 [self.paymentFlowClientDelegate onPaymentComplete:tokenizedLocalPayment error:nil];
             }
         }];
    }
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

- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/local-payment"];
}

- (NSString *)paymentFlowName {
    NSString *paymentType = self.paymentType != nil ? [self.paymentType lowercaseString] : @"unknown";
    return [NSString stringWithFormat:@"%@.local-payment", paymentType];
}

@end
