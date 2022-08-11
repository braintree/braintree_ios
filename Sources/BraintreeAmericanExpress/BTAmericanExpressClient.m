#import "BTAmericanExpressClient_Internal.h"

#if __has_include(<Braintree/BraintreeAmericanExpress.h>) // CocoaPods
#import <Braintree/BTAmericanExpressRewardsBalance.h>
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTAPIClient_Internal.h>

#else // Carthage & SPM
#import <BraintreeAmericanExpress/BTAmericanExpressRewardsBalance.h>
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif

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

- (void)getRewardsBalanceForNonce:(NSString *)nonce currencyIsoCode:(NSString *)currencyIsoCode completion:(void (^)(BTAmericanExpressRewardsBalance *, NSError *))completionBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"currencyIsoCode"] = currencyIsoCode;
    parameters[@"paymentMethodNonce"] = nonce;
    
    [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.start"];
    [self.apiClient GET:@"v1/payment_methods/amex_rewards_balance"
             parameters:parameters
             completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                 if (error) {
                     [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.error"];
                     completionBlock(nil, error);
                     return;
                 }
                 BTAmericanExpressRewardsBalance *rewardsBalance = [[BTAmericanExpressRewardsBalance alloc] initWithJSON:body];
                 [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.success"];
                 completionBlock(rewardsBalance, nil);
     }];
}

@end
