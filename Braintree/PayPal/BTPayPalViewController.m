#import "BTPayPalViewController_Internal.h"

#import "BTClient+BTPayPal.h"
#import "BTClient_Internal.h"
#import "BTErrors+BTPayPal.h"

#import "BTMutablePayPalPaymentMethod.h"

@interface BTPayPalViewController ()
@property (nonatomic, strong) NSError *failureError;
@property (nonatomic, strong) BTPayPalPaymentMethod *paymentMethod;
@end

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
                                                 userInfo:@{ NSLocalizedDescriptionKey: @"PayPalProfileSharingViewController could not be initialized. Perhaps client token did not contain a valid PayPal configuration. Please ensure that you have PayPal enabled and are including the configuration in your client token." }];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.client postAnalyticsEvent:@"ios.paypal.viewcontroller.will-appear"];
}

#pragma mark - PayPalProfileSharingDelegate implementation


- (void)userDidCancelPayPalProfileSharingViewController:(__unused PayPalProfileSharingViewController *)profileSharingViewController {
    [self.client postAnalyticsEvent:@"ios.paypal.viewcontroller.did-cancel"];
    if ([self.delegate respondsToSelector:@selector(payPalViewControllerDidCancel:)]) {
        [self.delegate payPalViewControllerDidCancel:self];
    }
}

- (void)payPalProfileSharingViewController:(__unused PayPalProfileSharingViewController *)profileSharingViewController
            userWillLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization
                           completionBlock:(PayPalProfileSharingDelegateCompletionBlock)completionBlock {
    NSString *authCode = profileSharingAuthorization[@"response"][@"code"];

    [self.client postAnalyticsEvent:@"ios.paypal.viewcontroller.will-log-in"];
    if (authCode == nil) {
        self.failureError = [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTPayPalUnknownError userInfo:@{NSLocalizedDescriptionKey: @"PayPal flow failed to generate an auth code" }];
        completionBlock();
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
                                                self.paymentMethod = paypalPaymentMethod;
                                                completionBlock();
                                            } failure:^(NSError *error) {
                                                self.failureError = error;
                                                completionBlock();
                                            }];
    }
}

- (void)payPalProfileSharingViewController:(__unused PayPalProfileSharingViewController *)profileSharingViewController
             userDidLogInWithAuthorization:(__unused NSDictionary *)profileSharingAuthorization {

    if (self.paymentMethod && !self.failureError) {
        [self.client postAnalyticsEvent:@"ios.paypal.viewcontroller.success"];
        if ([self.delegate respondsToSelector:@selector(payPalViewController:didCreatePayPalPaymentMethod:)]) {
            [self.delegate payPalViewController:self didCreatePayPalPaymentMethod:self.paymentMethod];
        }
    } else {
        [self.client postAnalyticsEvent:@"ios.paypal.viewcontroller.error"];
        if ([self.delegate respondsToSelector:@selector(payPalViewController:didFailWithError:)]) {
            [self.delegate payPalViewController:self didFailWithError:self.failureError];
        }
    }
}


@end
