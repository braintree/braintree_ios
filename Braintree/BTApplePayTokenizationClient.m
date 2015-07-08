#import "BTApplePayTokenizationClient.h"
#import "BTAPIClient_Internal.h"

NSString *const BTApplePayErrorDomain = @"com.braintreepayments.BTApplePayErrorDomain";

@interface BTApplePayTokenizationClient ()
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@implementation BTApplePayTokenizationClient

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

- (void)tokenizeApplePayPayment:(PKPayment *)payment completion:(void (^)(BTTokenizedApplePayPayment *, NSError *))completionBlock {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }

        if ([remoteConfiguration[@"applePay"][@"status"].asString isEqualToString:@"off"]) {
            NSError *error = [NSError errorWithDomain:BTApplePayErrorDomain
                                                 code:BTApplePayErrorTypeUnsupported
                                             userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not enabled for this merchant. Please ensure that Apple Pay is enabled in the control panel and then try saving an Apple Pay payment method again." }];
            completionBlock(nil, error);
            return;
        }
        if (!payment) {
            NSError *error = [NSError errorWithDomain:BTApplePayErrorDomain
                                                 code:BTApplePayErrorTypeUnsupported
                                             userInfo:@{NSLocalizedDescriptionKey: @"A valid PKPayment is required."}];
            completionBlock(nil, error);
            return;
        }

        [self.apiClient POST:@"v1/payment_methods/apple_payment_tokens"
                  parameters:@{
                               @"applePaymentToken": [self parametersForPaymentToken:payment.token],
                               @"_meta": self.apiClient.metadata.parameters
                               }
                  completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                      if (error) {
                          completionBlock(nil, error);
                          return;
                      }

                      BTJSON *applePayCard = body[@"applePayCards"][0];
                      BTTokenizedApplePayPayment *tokenized = [[BTTokenizedApplePayPayment alloc] initWithPaymentMethodNonce:applePayCard[@"nonce"].asString description:applePayCard[@"description"].asString];

                      completionBlock(tokenized, nil);
                  }];
    }];

}

- (NSDictionary *)parametersForPaymentToken:(PKPaymentToken *)token {
    return @{
             @"paymentData": [token.paymentData base64EncodedStringWithOptions:0],
             @"transactionIdentifier": token.transactionIdentifier,
             @"paymentInstrumentName": token.paymentInstrumentName,
             @"paymentNetwork": token.paymentNetwork
             };
}
@end
