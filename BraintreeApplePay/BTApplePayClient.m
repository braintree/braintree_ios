#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#import "BTPaymentMethodNonce.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#endif

#import "BTApplePayClient_Internal.h"
#import "BTConfiguration+ApplePay.h"

NSString *const BTApplePayErrorDomain = @"com.braintreepayments.BTApplePayErrorDomain";

// To retain the client that is presenting and tokenization Apple Pay
static BTApplePayClient *presentingClient;

@interface BTApplePayClient () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong, nullable) BTApplePayCardNonce *tokenizationNonce;
@property (nonatomic, strong, nullable) NSError *tokenizationError;
@property (nonatomic, strong, nullable) void (^completionBlock)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error);

@end

@implementation BTApplePayClient

+ (void)load {
    if (self == [BTApplePayClient class]) {
        [[BTPaymentMethodNonceParser sharedParser] registerType:@"ApplePay" withParsingBlock:^BTPaymentMethodNonce * _Nullable(BTJSON * _Nonnull applePayCard) {
            NSString *cardType = applePayCard[@"details"][@"cardType"] ? [applePayCard[@"details"][@"cardType"] asString] : @"ApplePay";
            return [[BTApplePayCardNonce alloc] initWithNonce:[applePayCard[@"nonce"] asString] localizedDescription:[applePayCard[@"description"] asString] type:cardType];
        }];
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

- (void)presentApplePayFromViewController:(UIViewController *)viewController withPaymentRequest:(PKPaymentRequest *)paymentRequest completion:(void (^)(BTApplePayCardNonce * _Nullable, NSError * _Nullable))completionBlock {
    presentingClient = self;
    self.completionBlock = completionBlock;
    PKPaymentAuthorizationViewController *authViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    authViewController.delegate = self;
    [viewController presentViewController:authViewController animated:YES completion:nil];
}

- (void)tokenizeApplePayPayment:(PKPayment *)payment completion:(void (^)(BTApplePayCardNonce *, NSError *))completionBlock {
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTApplePayErrorDomain
                                             code:BTApplePayErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTApplePayClient tokenization failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }
    
    [self.apiClient sendAnalyticsEvent:@"ios.apple-pay.start"];
   
    if (!payment) {
        NSError *error = [NSError errorWithDomain:BTApplePayErrorDomain
                                             code:BTApplePayErrorTypeUnsupported
                                         userInfo:@{NSLocalizedDescriptionKey: @"A valid PKPayment is required."}];
        completionBlock(nil, error);
        [self.apiClient sendAnalyticsEvent:@"ios.apple-pay.error.invalid-payment"];
        return;
    }
    
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            [self.apiClient sendAnalyticsEvent:@"ios.apple-pay.error.configuration"];
            completionBlock(nil, error);
            return;
        }

        if (![configuration.json[@"applePay"][@"status"] isString] ||
            [[configuration.json[@"applePay"][@"status"] asString] isEqualToString:@"off"]) {
            NSError *error = [NSError errorWithDomain:BTApplePayErrorDomain
                                                 code:BTApplePayErrorTypeUnsupported
                                             userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not enabled for this merchant. Please ensure that Apple Pay is enabled in the control panel and then try saving an Apple Pay payment method again." }];
            completionBlock(nil, error);
            [self.apiClient sendAnalyticsEvent:@"ios.apple-pay.error.disabled"];
            return;
        }
        
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[@"applePaymentToken"] = [self parametersForPaymentToken:payment.token];
        parameters[@"_meta"] = @{
                                 @"source" : self.apiClient.metadata.sourceString,
                                 @"integration" : self.apiClient.metadata.integrationString,
                                 @"sessionId" : self.apiClient.metadata.sessionId,
                                 };
        
        [self.apiClient POST:@"v1/payment_methods/apple_payment_tokens"
                  parameters:parameters
                  completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                      if (error) {
                          completionBlock(nil, error);
                          [self.apiClient sendAnalyticsEvent:@"ios.apple-pay.error.tokenization"];
                          return;
                      }

                      BTJSON *applePayCard = body[@"applePayCards"][0];
                      NSString *cardType = applePayCard[@"details"][@"cardType"] ? [applePayCard[@"details"][@"cardType"] asString] : @"ApplePay";
                      BTApplePayCardNonce *tokenized = [[BTApplePayCardNonce alloc] initWithNonce:[applePayCard[@"nonce"] asString] localizedDescription:[applePayCard[@"description"] asString] type:cardType];

                      completionBlock(tokenized, nil);
                      [self.apiClient sendAnalyticsEvent:@"ios.apple-pay.success"];
                  }];
    }];
}

- (NSDictionary *)parametersForPaymentToken:(PKPaymentToken *)token {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];

    mutableParameters[@"paymentData"] = [token.paymentData base64EncodedStringWithOptions:0];
    mutableParameters[@"transactionIdentifier"] = token.transactionIdentifier;

    if ([PKPaymentMethod class]) {
        mutableParameters[@"paymentInstrumentName"] = token.paymentMethod.displayName;
        mutableParameters[@"paymentNetwork"] = token.paymentMethod.network;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        mutableParameters[@"paymentInstrumentName"] = token.paymentInstrumentName;
        mutableParameters[@"paymentNetwork"] = token.paymentNetwork;
#pragma clang diagnostic pop
    }

    return [mutableParameters copy];
}

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    [self tokenizeApplePayPayment:payment completion:^(__unused BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tokenizationError = error;
            self.tokenizationNonce = tokenizedApplePayPayment;
            if (error) {
                completion(PKPaymentAuthorizationStatusFailure);
            } else {
                completion(PKPaymentAuthorizationStatusSuccess);
            }

        });


    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        if(self.completionBlock) {
            self.completionBlock(self.tokenizationNonce, self.tokenizationError);
        }
    }];
}

@end
