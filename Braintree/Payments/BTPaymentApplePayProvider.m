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
    static NSString *const failureEvent = @"ios.apple-pay-provider.check.fail";
    static NSString *const successEvent = @"ios.apple-pay-provider.check.succeed";

    BOOL result = [self canAuthorizeApplePayPaymentWithoutAnalytics];
    [self.client postAnalyticsEvent:result ? successEvent : failureEvent];
    return result;
}

- (BOOL)canAuthorizeApplePayPaymentWithoutAnalytics {
    if (![PKPayment class]) {
        return NO;
    }
    
    if (self.client.configuration.applePayConfiguration.status == BTClientApplePayStatusOff) {
        return NO;
    }

    if (![self paymentAuthorizationViewControllerCanMakePayments]) {
        return NO;
    }

    return YES;
}

- (void)authorizeApplePay {
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
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Delegate must not be nil to start Apple Pay authorization" }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    if (self.client.configuration.applePayConfiguration.status == BTClientApplePayStatusOff) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorOptionNotSupported
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not enabled for this merchant account" }];
        [self informDelegateDidFailWithError:error];
        return;
    }
    
    if (![self canAuthorizeApplePayPaymentWithoutAnalytics]) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize a Apple Pay authorization view controller. Check device, OS version, cards in Passbook and configuration." }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    PKPaymentRequest *paymentRequest = self.paymentRequest;

    if (!paymentRequest) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize an Apple Pay PKPaymentRequest based on the client token configuration." }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    if (![paymentRequest.paymentSummaryItems count]) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay cannot be initialized because paymentSummaryItems are not set. Please set them via the BTPaymentProvider paymentSummaryItems" }];
        [self informDelegateDidFailWithError:error];
        return;
    }


    UIViewController *paymentAuthorizationViewController;
    if ([[self class] isSimulator]) {
        paymentAuthorizationViewController = ({
            BTMockApplePayPaymentAuthorizationViewController *mockVC = [[BTMockApplePayPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
            mockVC.delegate = self;
            mockVC;
        });
    } else {
        paymentAuthorizationViewController = ({
            PKPaymentAuthorizationViewController *realVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
            realVC.delegate = self;
            realVC;
        });
        if (paymentAuthorizationViewController == nil) {
            NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                                 code:BTPaymentProviderErrorInitialization
                                             userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize a Apple Pay authorization view controller. Check device, OS version, cards in Passbook and configuration." }];
            [self informDelegateDidFailWithError:error];
            return;
        }
    }

    [self informDelegateRequestsPresentationOfViewController:paymentAuthorizationViewController];
}

- (PKPaymentRequest *)paymentRequest {
    if (![PKPaymentRequest class]) {
        return nil;
    }

    PKPaymentRequest *paymentRequest = self.client.configuration.applePayConfiguration.paymentRequest;
    if (self.paymentSummaryItems) {
        paymentRequest.paymentSummaryItems = self.paymentSummaryItems;
    }

    if (self.requiredBillingAddressFields) {
        paymentRequest.requiredBillingAddressFields = self.requiredBillingAddressFields;
    }

    if (self.requiredShippingAddressFields) {
        paymentRequest.requiredShippingAddressFields = self.requiredShippingAddressFields;
    }

    if (self.shippingAddress) {
        paymentRequest.shippingAddress = self.shippingAddress;
    }

    if (self.billingAddress) {
        paymentRequest.billingAddress = self.billingAddress;
    }

    if (self.shippingMethods) {
        paymentRequest.shippingMethods = self.shippingMethods;
    }

    if (self.supportedNetworks) {
        paymentRequest.supportedNetworks = self.supportedNetworks;
    }

    return paymentRequest;
}

- (void)setBillingAddress:(ABRecordRef)billingAddress {
    _billingAddress = CFRetain(billingAddress);
}

- (void)setShippingAddress:(ABRecordRef)shippingAddress {
    _shippingAddress = CFRetain(shippingAddress);
}

- (void)dealloc {
    if (_billingAddress) {
        CFRelease(_billingAddress);
    }

    if (_shippingAddress) {
        CFRelease(_shippingAddress);
    }
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
        return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.paymentRequest.supportedNetworks];
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
    [self.client saveApplePayPayment:payment
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
    [self.client postAnalyticsEvent:@"ios.apple-pay-provider.completion.succeed"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didCreatePaymentMethod:)]) {
        [self.delegate paymentMethodCreator:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.apple-pay-provider.completion.fail"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    [self.client postAnalyticsEvent:@"ios.apple-pay-provider.completion.cancel"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorDidCancel:)]) {
        [self.delegate paymentMethodCreatorDidCancel:self];
    }
}

@end
