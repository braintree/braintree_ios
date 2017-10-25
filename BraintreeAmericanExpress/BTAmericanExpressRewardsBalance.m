#import "BTAmericanExpressRewardsBalance.h"

@implementation BTAmericanExpressRewardsBalance

- (instancetype)initWithJSON:(BTJSON *)json
{
    if (self = [super init]) {
        _errorCode = [json[@"error"][@"code"] asString];
        _errorMessage = [json[@"error"][@"message"] asString];
        _conversionRate = [json[@"conversionRate"] asString];
        _currencyAmount = [json[@"currencyAmount"] asString];
        _currencyIsoCode = [json[@"currencyIsoCode"] asString];
        _requestId = [json[@"requestId"] asString];
        _rewardsAmount = [json[@"rewardsAmount"] asString];
        _rewardsUnit = [json[@"rewardsUnit"] asString];
    }
    return self;
}

@end

