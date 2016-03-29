#import "BTUnionPayRequest_Internal.h"

@implementation BTUnionPayRequest

- (instancetype)initWithCard:(BTCard *)card mobilePhoneNumber:(NSString *)phoneNumber {
    if (self = [super init]) {
        _card = card;
        self.mobilePhoneNumber = phoneNumber;
    }
    return self;
}

@end
