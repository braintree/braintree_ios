#import "BTClientApplePayConfiguration.h"

@implementation BTClientApplePayConfiguration

- (instancetype)initWithConfigurationObject:(id)configurationObject {
    self = [super init];
    if (self) {

        if ([configurationObject respondsToSelector:@selector(objectForKeyedSubscript:)]) {
            // merchant ID
            if ([configurationObject[@"merchantId"] isKindOfClass:[NSString class]]) {
                _merchantId = [configurationObject[@"merchantId"] copy];
            }

            // status
            NSString *statusString = configurationObject[@"status"];
            _status = [[self class] statusTypeForString:statusString];

        } else if ([configurationObject isKindOfClass:[NSString class]]) {
            _status = [[self class] statusTypeForString:configurationObject];
            if (_status == BTClientApplePayStatusMock) {
                _merchantId = @"mock-merchant-id";
            }
        } else {
            _status = BTClientApplePayStatusOff;
        }
    }
    return self;
}

+ (BTClientApplePayStatusType)statusTypeForString:(NSString *)statusString {
    if ([statusString isEqualToString:@"mock"]) {
        return BTClientApplePayStatusMock;
    } else if([statusString isEqualToString:@"production"]) {
        return BTClientApplePayStatusProduction;
    } else {
        return BTClientApplePayStatusOff;
    }

}

@end
