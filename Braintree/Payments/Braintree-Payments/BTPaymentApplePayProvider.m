@import PassKit;

#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"
#import "BTPaymentMethodCreationDelegate.h"
#import "BTPaymentProviderErrors.h"

@interface BTPaymentApplePayProvider () <BTMockApplePayPaymentAuthorizationViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>
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

    return YES;
}

- (void)authorizeApplePay {
    if (![self canAuthorizeApplePayPayment]) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize a Apple Pay authorization view controller. Check device, OS version and configuration received via client token. Is Apple Pay enabled?" }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    UIViewController *paymentAuthorizationViewController;
    if ([self isSimulator]) {
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

#pragma mark PKPaymentAuthorizationViewController Delegate

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(__unused PKPayment *)payment
                                completion:(__unused void (^)(PKPaymentAuthorizationStatus))completion {
    completion(PKPaymentAuthorizationStatusFailure);
}

- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller {
    [self informDelegateDidFailWithError:[NSError errorWithDomain:BTPaymentProviderErrorDomain
                                                         code:BTPaymentProviderErrorUnknown
                                                     userInfo:@{ NSLocalizedDescriptionKey: @"paymentAuthorizationViewControllerDidFinish is not yet implemented" }]];
}

#pragma mark MockApplePayPaymentAuthorizationViewController Delegate

- (void)mockApplePayPaymentAuthorizationViewController:(__unused BTMockApplePayPaymentAuthorizationViewController *)viewController
                                   didAuthorizePayment:(__unused PKPayment *)payment
                                            completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    completion(PKPaymentAuthorizationStatusFailure);
}

- (void)mockApplePayPaymentAuthorizationViewControllerDidFinish:(__unused BTMockApplePayPaymentAuthorizationViewController *)viewController {
    [self informDelegateDidFailWithError:[NSError errorWithDomain:BTPaymentProviderErrorDomain
                                                             code:BTPaymentProviderErrorUnknown
                                                         userInfo:@{ NSLocalizedDescriptionKey: @"mockApplePayPaymentAuthorizationViewControllerDidFinish" }]];
}

#pragma mark Delegate Informers

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsPresentationOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:viewController];
    }
}

@end
