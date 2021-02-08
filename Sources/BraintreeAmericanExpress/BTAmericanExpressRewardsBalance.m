#if __has_include(<Braintree/BraintreeAmericanExpress.h>)
#import <Braintree/BTAmericanExpressRewardsBalance.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeAmericanExpress/BTAmericanExpressRewardsBalance.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

@implementation BTAmericanExpressRewardsBalance

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        _errorCode = [json[@"error"][@"code"] asString];
        _errorMessage = [json[@"error"][@"message"] asString];
        _conversionRate = [json[@"conversionRate"] asString];
        _currencyAmount = [json[@"currencyAmount"] asString];
        _currencyIsoCode = [json[@"currencyIsoCode"] asString];
        _requestID = [json[@"requestId"] asString];
        _rewardsAmount = [json[@"rewardsAmount"] asString];
        _rewardsUnit = [json[@"rewardsUnit"] asString];
    }
    return self;
}

@end

