@import PassKit;

#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"


@interface BTPaymentApplePayProvider ()
@property (nonatomic, strong) BTClient *client;
@end

@implementation BTPaymentApplePayProvider

- (instancetype)initWithClient:(BTClient *)client {
    if (self) {
        self.client = client;
    }
    return self;
}

- (BOOL)canAuthorizeApplePayPayment {
    if (self.client.applePayConfiguration.status == BTClientApplePayStatusOff) {
        return NO;
    }

    if (![self paymentAuthorizationViewControllerCanMakePayments]) {
        return NO;
    }

    if (![self paymentAuthorizationViewControllerCanMakePayments]) {
        return NO;
    }

    return YES;
}

- (void)authorizeApplePayPayment {
    // TODO - Implement me
}

- (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL)paymentAuthorizationViewControllerCanMakePayments {
#ifdef __IPHONE_8_0
    if ([self isSimulator]) {
        return [BTMockApplePayPaymentAuthorizationViewController canMakePayments];
    } else {
        return [PKPaymentAuthorizationViewController canMakePayments];
    }
    return YES;
#else
    return NO;
#endif
}

@end
