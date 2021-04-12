#ifdef COCOAPODS
#import <Braintree/BTVenmoRequest.h>
#else
#import <BraintreeVenmo/BTVenmoRequest.h>
#endif

@implementation BTVenmoRequest

- (NSString *)paymentMethodUsageAsString {
    switch(self.paymentMethodUsage) {
        case BTVenmoPaymentMethodUsageMultiUse:
            return @"MULTI_USE";
        case BTVenmoPaymentMethodUsageSingleUse:
            return @"SINGLE_USE";
        default:
            return nil;
    }
}

@end
