#import "BTThreeDSecureResponse.h"

@implementation BTThreeDSecureResponse

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<BTThreeDSecureResponse: %p success:%@ paymentMethod:%@ errorMessage:%@ threeDSecureInfo:%@>", self, self.success ? @"YES" : @"NO", self.paymentMethod, self.errorMessage, self.threeDSecureInfo];
}

@end
