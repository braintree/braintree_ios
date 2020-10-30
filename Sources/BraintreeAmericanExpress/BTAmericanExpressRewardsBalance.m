#import <BraintreeAmericanExpress/BTAmericanExpressRewardsBalance.h>
#import <BraintreeCore/BraintreeCore.h>

@implementation BTAmericanExpressRewardsBalance

- (instancetype)initWithJSON:(BTJSON *)json {
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

// TODO: Remove
// This code is a test to see if a merchant includes CardinalMobile directly in their app, if this method will return `true`
- (BOOL)isCardinalAvailable {
    return NSClassFromString(@"CardinalSession") != nil;
}

@end

