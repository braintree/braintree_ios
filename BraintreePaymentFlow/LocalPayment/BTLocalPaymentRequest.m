#import "BTLocalPaymentRequest.h"
#import "BTConfiguration+LocalPayment.h"
#if __has_include("BTLogger_Internal.h")
#import "BTLogger_Internal.h"
#else
#import <BraintreeCore/BTLogger_Internal.h>
#endif
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#if __has_include("PayPalDataCollector.h")
#import "PPDataCollector.h"
#else
#import <PayPalDataCollector/PPDataCollector.h>
#endif
#import "BTPaymentFlowDriver_Internal.h"
#import "BTLocalPaymentRequest.h"
#import "Braintree-Version.h"
#import <SafariServices/SafariServices.h>
#import "BTLocalPaymentResult.h"
#import "BTPaymentFlowDriver+LocalPayment_Internal.h"

@interface BTLocalPaymentRequest ()

@property (nonatomic, copy, nullable) NSString *paymentId;
@property (nonatomic, weak) id<BTPaymentFlowDriverDelegate> paymentFlowDriverDelegate;
@property (nonatomic, strong) NSString *correlationId;

@end

@implementation BTLocalPaymentRequest

- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate {
    self.paymentFlowDriverDelegate = delegate;
    BTLocalPaymentRequest *localPaymentRequest = (BTLocalPaymentRequest *)request;
    self.correlationId = [PPDataCollector clientMetadataID:nil];
    [apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, NSError *configurationError) {
        if (configurationError) {
            [delegate onPaymentComplete:nil error:configurationError];
            return;
        }

        NSError *integrationError;

        if ([self.paymentFlowDriverDelegate returnURLScheme] == nil || [[self.paymentFlowDriverDelegate returnURLScheme] isEqualToString:@""]) {
            [[BTLogger sharedLogger] critical:@"Local Payment requires a return URL scheme to be configured via [BTAppSwitch setReturnURLScheme:]"];
            integrationError = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                 code:BTPaymentFlowDriverErrorTypeInvalidReturnURL
                                             userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app or browser switch."}];
        } else if (![configuration isLocalPaymentEnabled]) {
            [[BTLogger sharedLogger] critical:@"Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments."];
            integrationError = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                 code:BTPaymentFlowDriverErrorTypeDisabled
                                             userInfo:@{NSLocalizedDescriptionKey: @"Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments."}];
        } else if (localPaymentRequest.localPaymentFlowDelegate == nil) {
            [[BTLogger sharedLogger] critical:@"BTLocalPaymentRequest localPaymentFlowDelegate can not be nil."];
            integrationError = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                 code:BTPaymentFlowDriverErrorTypeIntegration
                                             userInfo:@{NSLocalizedDescriptionKey: @"Failed to begin payment flow: BTLocalPaymentRequest localPaymentFlowDelegate can not be nil."}];
        } else if (localPaymentRequest.amount == nil || localPaymentRequest.paymentType == nil) {
            [[BTLogger sharedLogger] critical:@"BTLocalPaymentRequest amount and paymentType can not be nil."];
            integrationError = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                 code:BTPaymentFlowDriverErrorTypeIntegration
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

        if (localPaymentRequest.merchantAccountId) {
            params[@"merchant_account_id"] = localPaymentRequest.merchantAccountId;
        }

        params[@"experience_profile"] = @{
                                          @"no_shipping": @(!localPaymentRequest.isShippingAddressRequired)
                                          };

        [apiClient POST:@"v1/paypal_hermes/create_payment_resource"
                   parameters:params
                   completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
             if (!error) {
                 self.paymentId = [body[@"paymentResource"][@"paymentToken"] asString];
                 NSString *approvalUrl = [body[@"paymentResource"][@"redirectUrl"] asString];
                 NSURL *url = [NSURL URLWithString:approvalUrl];

                 if (self.paymentId && url) {
                     [self.localPaymentFlowDelegate localPaymentStarted:self paymentId:self.paymentId start:^{
                         [delegate onPaymentWithURL:url error:error];
                     }];
                 } else {
                     [[BTLogger sharedLogger] critical:@"Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists."];
                     NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                          code:BTPaymentFlowDriverErrorTypeAppSwitchFailed
                                                      userInfo:@{NSLocalizedDescriptionKey: @"Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists."}];
                     [delegate onPaymentComplete:nil error:error];
                     return;
                 }
             } else {
                 [delegate onPaymentWithURL:nil error:error];
             }
         }];
    }];
}

- (void)handleOpenURL:(__unused NSURL *)url {
    if ([url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/local-payment/cancel"]) {
        // canceled
        NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                             code:BTPaymentFlowDriverErrorTypeCanceled
                                         userInfo:@{}];
        [self.paymentFlowDriverDelegate onPaymentComplete:nil error:error];
    } else {
        // success
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"paypal_account"] = [@{} mutableCopy];
        parameters[@"paypal_account"][@"response"] = @{ @"webURL": url.absoluteString };
        parameters[@"paypal_account"][@"response_type"] = @"web";
        parameters[@"paypal_account"][@"options"] = @{ @"validate": @NO };
        parameters[@"paypal_account"][@"intent"] = @"sale";

        if (self.correlationId) {
            parameters[@"paypal_account"][@"correlation_id"] = self.correlationId;
        }

        if (self.merchantAccountId) {
            parameters[@"merchant_account_id"] = self.merchantAccountId;
        }

        BTClientMetadata *metadata =  self.paymentFlowDriverDelegate.apiClient.metadata;
        parameters[@"_meta"] = @{
                                 @"source" : metadata.sourceString,
                                 @"integration" : metadata.integrationString,
                                 @"sessionId" : metadata.sessionId,
                                 };

        [self.paymentFlowDriverDelegate.apiClient POST:@"/v1/payment_methods/paypal_accounts"
                  parameters:parameters
                  completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
         {
             if (error) {
                 [self.paymentFlowDriverDelegate onPaymentComplete:nil error:error];
                 return;
             } else {
                 BTJSON *payPalAccount = body[@"paypalAccounts"][0];
                 NSString *nonce = [payPalAccount[@"nonce"] asString];
                 NSString *description = [payPalAccount[@"description"] asString];
                 NSString *type = [payPalAccount[@"type"] asString];

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

                 BTLocalPaymentResult *tokenizedLocalPayment = [[BTLocalPaymentResult alloc] initWithNonce:nonce
                                                                                                description:description
                                                                                                       type:type
                                                                                                      email:email
                                                                                                  firstName:firstName
                                                                                                   lastName:lastName
                                                                                                      phone:phone
                                                                                             billingAddress:billingAddress
                                                                                            shippingAddress:shippingAddress
                                                                                           clientMetadataId:clientMetadataId
                                                                                                    payerId:payerId];
                 [self.paymentFlowDriverDelegate onPaymentComplete:tokenizedLocalPayment error:nil];
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

- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(__unused NSString *)sourceApplication {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/local-payment"];
}

- (NSString *)paymentFlowName {
    NSString *paymentType = self.paymentType != nil ? [self.paymentType lowercaseString] : @"unknown";
    return [NSString stringWithFormat:@"%@.local-payment", paymentType];
}

@end
