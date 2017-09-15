#import "BTBinData.h"

@implementation BTBinData

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        if (json != nil) {
            _prepaid = [json[@"prepaid"] asString] ? [json[@"prepaid"] asString] : @"Unknown";
            _healthcare = [json[@"healthcare"] asString] ? [json[@"healthcare"] asString] : @"Unknown";
            _debit = [json[@"debit"] asString] ? [json[@"debit"] asString] : @"Unknown";
            _durbinRegulated = [json[@"durbinRegulated"] asString] ? [json[@"durbinRegulated"] asString] : @"Unknown";
            _commercial = [json[@"commercial"] asString] ? [json[@"commercial"] asString] : @"Unknown";
            _payroll = [json[@"payroll"] asString] ? [json[@"payroll"] asString] : @"Unknown";
            _issuingBank = [json[@"issuingBank"] asString] ? [json[@"issuingBank"] asString] : @"";
            _countryOfIssuance = [json[@"countryOfIssuance"] asString] ? [json[@"countryOfIssuance"] asString] : @"";
            _productId = [json[@"productId"] asString] ? [json[@"productId"] asString] : @"";
        }
    }
    return self;
}

@end
