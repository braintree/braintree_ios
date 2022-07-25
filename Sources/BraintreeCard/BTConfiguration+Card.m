#import "BTConfiguration+Card.h"

#import "BraintreeCoreSwiftImports.h"

@implementation BTConfiguration (Card)

- (BOOL)collectFraudData {
    return [self.json[@"creditCards"][@"collectDeviceData"] isTrue];
}

@end
