#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import "BTAmericanExpressClient_Internal.h"

NSString *const BTAmericanExpressErrorDomain = @"com.braintreepayments.BTAmericanExpressErrorDomain";

@interface BTAmericanExpressClient ()
@end

@implementation BTAmericanExpressClient

#pragma mark - Initialization

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

#pragma mark - Public methods

- (void)getRewardsBalance:(NSDictionary *)options completion:(void (^)(NSDictionary *, NSError *))completionBlock {
    NSString *nonce = options[@"nonce"];
    NSString *currencyIsoCode = options [@"currencyIsoCode"];
    if (!nonce) {
        NSError *error = [NSError errorWithDomain:BTAmericanExpressErrorDomain
                                             code:BTAmericanExpressErrorTypeInvalidParameters
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Invalid Parameters: A 'nonce' is required in the options." }];
        completionBlock(nil, error);
        return;
    } else if (!currencyIsoCode) {
        NSError *error = [NSError errorWithDomain:BTAmericanExpressErrorDomain
                                             code:BTAmericanExpressErrorTypeInvalidParameters
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Invalid Parameters: A 'currencyIsoCode' is required in the options." }];
        completionBlock(nil, error);
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"currencyIsoCode"] = currencyIsoCode;
    parameters[@"paymentMethodNonce"] = nonce;
    parameters[@"_meta"] = @{
                             @"source" : self.apiClient.metadata.sourceString,
                             @"integration" : self.apiClient.metadata.integrationString,
                             @"sessionId" : self.apiClient.metadata.sessionId,
                             };
    
    [self.apiClient GET:@"v1/payment_methods/amex_rewards_balance"
             parameters:parameters
             completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                 if (error) {
                     completionBlock(nil, error);
                     [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.error"];
                     return;
                 }
                 NSDictionary *payload = [body asDictionary];
                 [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.success"];
                 completionBlock(payload, nil);
     }];
}

@end
