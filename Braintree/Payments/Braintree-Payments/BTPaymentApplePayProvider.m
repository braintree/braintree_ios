@import PassKit;

#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"
#import "BTPaymentMethodCreationDelegate.h"
#import "BTPaymentProviderErrors.h"
#import "BTLogger_Internal.h"

@interface BTPaymentApplePayProvider () <BTMockApplePayPaymentAuthorizationViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, strong) NSError *applePayError;
@property (nonatomic, strong) BTPaymentMethod *applePayPaymentMethod;
@end

@implementation BTPaymentApplePayProvider

- (instancetype)initWithClient:(BTClient *)client {
    if (self) {
        self.client = client;
    }
    return self;
}

- (BOOL)canAuthorizeApplePayPayment {
    if (![PKPayment class]) {
        return NO;
    }

    if (self.client.applePayConfiguration.status == BTClientApplePayStatusOff) {
        return NO;
    }

    if (![self paymentAuthorizationViewControllerCanMakePayments]) {
        return NO;
    }

    return YES;
}

- (void)authorizeApplePay {

    [[BTLogger sharedLogger] warning:@"⚠️⚠️⚠️ Braintree's API for Apple Pay is PRE-RELEASE and subject to change! ⚠️⚠️⚠️"];

    if (![PKPayment class]) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorOptionNotSupported
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not supported in this version of the iOS SDK" }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    if (!self.delegate) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Delegate must not be nil to start Apple Pay authorization" }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    if (self.client.applePayConfiguration.status == BTClientApplePayStatusOff) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorOptionNotSupported
                                         userInfo:@{NSLocalizedDescriptionKey: @"Apple Pay is not enabled for this merchant account"}];
        [self.delegate paymentMethodCreator:self didFailWithError:error];
        return;
    }

    if (![self canAuthorizeApplePayPayment]) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize a Apple Pay authorization view controller. Check device, OS version and configuration received via client token. Is Apple Pay enabled?" }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    UIViewController *paymentAuthorizationViewController;


    if ([[self class] isSimulator]) {
        paymentAuthorizationViewController = ({
            BTMockApplePayPaymentAuthorizationViewController *mockVC = [[BTMockApplePayPaymentAuthorizationViewController alloc] initWithPaymentRequest:self.paymentRequest];
            mockVC.delegate = self;
            mockVC;
        });
    } else {
        paymentAuthorizationViewController = ({
            PKPaymentAuthorizationViewController *realVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:self.paymentRequest];
            realVC.delegate = self;
            realVC;
        });

    }

    [self informDelegateRequestsPresentationOfViewController:paymentAuthorizationViewController];
}

- (PKPaymentRequest *)paymentRequest {
    if (![PKPaymentRequest class]) {
        return nil;
    }
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = self.client.applePayConfiguration.merchantId;
    // TODO - Retrieve these payment related values from client token
    paymentRequest.countryCode = @"US";
    paymentRequest.currencyCode = @"USD";

    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;

    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"1"];
    paymentRequest.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Purchase" amount:amount] ];

    return paymentRequest;
}

#pragma mark Internal Helpers - Exposed for Testing

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL)paymentAuthorizationViewControllerCanMakePayments {
    if (![PKPaymentAuthorizationViewController class]) {
        return NO;
    }
    if ([[self class] isSimulator]) {
        return [BTMockApplePayPaymentAuthorizationViewController canMakePayments];
    } else {
        return [PKPaymentAuthorizationViewController canMakePayments];
    }
}

#pragma mark PKPaymentAuthorizationViewController Delegate

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self applePayPaymentAuthorizationViewControllerDidAuthorizePayment:payment
                   completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self applePayPaymentAuthorizationViewControllerDidFinish:controller];
}

#pragma mark MockApplePayPaymentAuthorizationViewController Delegate

- (void)mockApplePayPaymentAuthorizationViewController:(__unused BTMockApplePayPaymentAuthorizationViewController *)viewController
                                   didAuthorizePayment:(PKPayment *)payment
                                            completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self applePayPaymentAuthorizationViewControllerDidAuthorizePayment:payment
                   completion:completion];
}

- (void)mockApplePayPaymentAuthorizationViewControllerDidFinish:(BTMockApplePayPaymentAuthorizationViewController *)viewController {
    [self applePayPaymentAuthorizationViewControllerDidFinish:viewController];
}

#pragma mark Payment Authorization

- (void)applePayPaymentAuthorizationViewControllerDidAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    BTClientApplePayRequest *request;
    if (self.client.applePayConfiguration.status != BTClientApplePayStatusMock) {
        request = [[BTClientApplePayRequest alloc] initWithApplePayPayment:payment];
    }

    [self.client saveApplePayPayment:request
                             success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                                 self.applePayPaymentMethod = applePayPaymentMethod;
                                 completion(PKPaymentAuthorizationStatusSuccess);
                             } failure:^(NSError *error) {
                                 self.applePayError = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                                                          code:BTPaymentProviderErrorPaymentMethodCreation
                                                                      userInfo:@{NSLocalizedDescriptionKey: @"Error processing Apple Payment with Braintree",
                                                                                 NSUnderlyingErrorKey: error}];
                                 completion(PKPaymentAuthorizationStatusFailure);
                             }];
}

- (void)applePayPaymentAuthorizationViewControllerDidFinish:(UIViewController *)viewController {
    if (self.applePayError) {
        [self informDelegateDidFailWithError:self.applePayError];
    } else if (self.applePayPaymentMethod) {
        [self informDelegateDidCreatePaymentMethod:self.applePayPaymentMethod];
    } else {
        [self informDelegateDidCancel];
    }

    self.applePayError = nil;
    self.applePayPaymentMethod = nil;
    
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
}

#pragma mark Delegate Informers

- (void)informDelegateWillPerformAppSwitch {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillPerformAppSwitch:)]) {
        [self.delegate paymentMethodCreatorWillPerformAppSwitch:self];
    }
}

- (void)informDelegateWillProcess {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillProcess:)]) {
        [self.delegate paymentMethodCreatorWillProcess:self];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsPresentationOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsDismissalOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsDismissalOfViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didCreatePaymentMethod:)]) {
        [self.delegate paymentMethodCreator:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorDidCancel:)]) {
        [self.delegate paymentMethodCreatorDidCancel:self];
    }
}

@end
