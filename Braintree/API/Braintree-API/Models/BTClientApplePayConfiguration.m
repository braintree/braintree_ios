#import "BTClientApplePayConfiguration.h"

@implementation BTClientApplePayConfiguration

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self && dictionary) {

        // merchant ID
        if ([dictionary[@"merchantId"] isKindOfClass:[NSString class]]) {
            _merchantId = [dictionary[@"merchantId"] copy];
        }

        // status
        NSString *statusString = dictionary[@"status"];
        if ([statusString isEqualToString:@"mock"]) {
            _status = BTClientApplePayStatusMock;
        } else if([statusString isEqualToString:@"production"]) {
            _status = BTClientApplePayStatusProduction;
        } else {
            _status = BTClientApplePayStatusOff;
        }
    }
    return self;
}

@end
