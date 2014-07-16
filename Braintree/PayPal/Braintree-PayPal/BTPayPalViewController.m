#import "BTPayPalViewController_Internal.h"

#import "BTClient+BTPayPal.h"
#import "BTErrors+BTPayPal.h"

#import "BTMutablePayPalPaymentMethod.h"

@implementation BTPayPalViewController

- (instancetype)initWithClient:(BTClient *)client
{
    self = [self init];
    if (self) {
        self.client = client;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.payPalFuturePaymentViewController) {
        NSError *error;
        [self.client btPayPal_preparePayPalMobileWithError:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
                [self.delegate payPalViewController:self didFailWithError:error];
            }
            self.view = nil;
            return;
        }

        self.payPalFuturePaymentViewController = [self.client btPayPal_futurePaymentFutureControllerWithDelegate:self];
        if (!self.payPalFuturePaymentViewController) {
            if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
                NSError *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                                     code:BTMerchantIntegrationErrorPayPalConfiguration
                                                 userInfo:@{ NSLocalizedDescriptionKey: @"PayPalFuturePaymentsViewController could not be initialized. Perhaps client token did not contain a valid PayPal configuration. Please ensure that you have PayPal enabled and are including the configuration in your client token." }];
                [self.delegate payPalViewController:self didFailWithError:error];
            }
            self.view = nil;
            return;
        }
    }

    if (self.payPalFuturePaymentViewController) {
        [self addChildViewController:self.payPalFuturePaymentViewController];
        [self.payPalFuturePaymentViewController willMoveToParentViewController:self];
        [self.view addSubview:self.payPalFuturePaymentViewController.view];
        [self.payPalFuturePaymentViewController didMoveToParentViewController:self];
    }
}

#pragma mark - PayPalFuturePaymentDelegate implementation

- (void)payPalFuturePaymentDidCancel:(__unused PayPalFuturePaymentViewController *)futurePaymentViewController {
    if ([self.delegate respondsToSelector:@selector(payPalViewControllerDidCancel:)]) {
        [self.delegate payPalViewControllerDidCancel:self];
    }
}

- (void)payPalFuturePaymentViewController:(__unused PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {

    NSString *authCode = futurePaymentAuthorization[@"response"][@"code"];
    if (authCode == nil) {
        if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTUnknownError userInfo:@{NSLocalizedDescriptionKey: @"PayPal flow failed to generate an auth code" }];
            [self.delegate payPalViewController:self didFailWithError:error];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(payPalViewControllerWillCreatePayPalPaymentMethod:)]) {
            [self.delegate payPalViewControllerWillCreatePayPalPaymentMethod:self];
        }

        [self.client savePaypalPaymentMethodWithAuthCode:authCode
                                           correlationId:[self.client btPayPal_applicationCorrelationId]
                                                 success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                     NSString *userDisplayStringFromPayPalSDK = futurePaymentAuthorization[@"user"][@"display_string"];
                                                     if (paypalPaymentMethod.email == nil && [userDisplayStringFromPayPalSDK isKindOfClass:[NSString class]]) {
                                                         BTMutablePayPalPaymentMethod *mutablePayPalPaymentMethod = [paypalPaymentMethod mutableCopy];
                                                         mutablePayPalPaymentMethod.email = userDisplayStringFromPayPalSDK;
                                                         paypalPaymentMethod = mutablePayPalPaymentMethod;
                                                     }
                                                     if ([self.delegate respondsToSelector:@selector(payPalViewController:didCreatePayPalPaymentMethod:)]) {
                                                         [self.delegate payPalViewController:self didCreatePayPalPaymentMethod:paypalPaymentMethod];
                                                     }
                                                 } failure:^(NSError *error) {
                                                     if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
                                                         [self.delegate payPalViewController:self didFailWithError:error];
                                                     }
                                                 }];
    }
}

@end
