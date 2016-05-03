#import "BTCardCapabilities.h"

@implementation BTCardCapabilities

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ isUnionPay = %@, isDebit = %@, isUnionPayEnrollmentRequired = %@, supportsTwoStepAuthAndCapture = %@", [super description], @(self.isUnionPay), @(self.isDebit), @(self.isUnionPayEnrollmentRequired), @(self.supportsTwoStepAuthAndCapture)];
}

@end
