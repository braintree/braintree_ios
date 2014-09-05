#import "BTPayPalViewController_Internal.h"

#import "BTClient+BTPayPal.h"
#import "BTClient_Metadata.h"
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

    if (!self.payPalProfileSharingViewController) {
        NSError *error;
        [self.client btPayPal_preparePayPalMobileWithError:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
                [self.delegate payPalViewController:self didFailWithError:error];
            }
            self.view = nil;
            return;
        }

        self.payPalProfileSharingViewController = [self.client btPayPal_profileSharingViewControllerWithDelegate:self];
        if (!self.payPalProfileSharingViewController) {
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

    if (self.payPalProfileSharingViewController) {
        [self addChildViewController:self.payPalProfileSharingViewController];
        [self.payPalProfileSharingViewController willMoveToParentViewController:self];
        [self.view addSubview:self.payPalProfileSharingViewController.view];
        [self.payPalProfileSharingViewController didMoveToParentViewController:self];
    }
}

#pragma mark - PayPalProfileSharingDelegate implementation


- (void)userDidCancelPayPalProfileSharingViewController:(__unused PayPalProfileSharingViewController *)profileSharingViewController {
    if ([self.delegate respondsToSelector:@selector(payPalViewControllerDidCancel:)]) {
        [self.delegate payPalViewControllerDidCancel:self];
    }
}

- (void)payPalProfileSharingViewController:(__unused PayPalProfileSharingViewController *)profileSharingViewController
             userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization {
    NSString *authCode = profileSharingAuthorization[@"response"][@"code"];

    if (authCode == nil) {
        if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTPayPalUnknownError userInfo:@{NSLocalizedDescriptionKey: @"PayPal flow failed to generate an auth code" }];
            [self.delegate payPalViewController:self didFailWithError:error];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(payPalViewControllerWillCreatePayPalPaymentMethod:)]) {
            [self.delegate payPalViewControllerWillCreatePayPalPaymentMethod:self];
        }

        BTClient *client = [self.client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
            metadata.source = BTClientMetadataSourcePayPalSDK;
        }];

        [client savePaypalPaymentMethodWithAuthCode:authCode
                                applicationCorrelationID:[client btPayPal_applicationCorrelationId]
                                                 success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                     NSString *userDisplayStringFromPayPalSDK = profileSharingAuthorization[@"user"][@"display_string"];
                                                     if (paypalPaymentMethod.email == nil && [userDisplayStringFromPayPalSDK isKindOfClass:[NSString class]]) {
                                                         BTMutablePayPalPaymentMethod *mutablePayPalPaymentMethod = [paypalPaymentMethod mutableCopy];
                                                         mutablePayPalPaymentMethod.email = userDisplayStringFromPayPalSDK;
                                                         if (!mutablePayPalPaymentMethod.description) {
                                                             mutablePayPalPaymentMethod.description = userDisplayStringFromPayPalSDK;
                                                         }
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
