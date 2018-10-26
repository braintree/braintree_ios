#import "BTConfiguration+Card.h"

@implementation BTConfiguration (Card)

- (BOOL)collectFraudData {
    return [self.json[@"creditCards"][@"collectDeviceData"] isTrue];
}

@end
