#if __has_include(<Braintree/BraintreeUnionPay.h>)
#import <Braintree/BTCardCapabilities.h>
#else
#import <BraintreeUnionPay/BTCardCapabilities.h>
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@implementation BTCardCapabilities
#pragma clang diagnostic pop

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ isUnionPay = %@, isDebit = %@, isSupported = %@, supportsTwoStepAuthAndCapture = %@", [super description], @(self.isUnionPay), @(self.isDebit), @(self.isSupported), @(self.supportsTwoStepAuthAndCapture)];
}

@end
