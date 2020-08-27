#import <BraintreeCard/BTConfiguration+Card.h>
#import <BraintreeCore/BTJSON.h>

@implementation BTConfiguration (Card)

- (BOOL)collectFraudData {
    return [self.json[@"creditCards"][@"collectDeviceData"] isTrue];
}

@end
