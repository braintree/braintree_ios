@import PassKit;

#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"
#import "BTPaymentMethodCreationDelegate.h"
#import "BTPaymentProviderErrors.h"
#import "BTLogger_Internal.h"
#import "BTAPIResponseParser.h"
#import "BTClientTokenApplePayStatusValueTransformer.h"

#if BT_ENABLE_APPLE_PAY
@interface BTPaymentApplePayProvider () <BTMockApplePayPaymentAuthorizationViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>
#else
@interface BTPaymentApplePayProvider ()
#endif

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, strong) NSError *applePayError;
@property (nonatomic, strong) BTPaymentMethod *applePayPaymentMethod;

- (instancetype)init NS_DESIGNATED_INITIALIZER DEPRECATED_ATTRIBUTE;

@end

@implementation BTPaymentApplePayProvider

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithClient:(BTClient *)client {
    self = [super init];
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
#if BT_ENABLE_APPLE_PAY
    if (![PKPayment class]) {
        return NO;
    }

    if (self.client.configuration.applePayStatus == BTClientApplePayStatusOff) {
        return NO;
    }

    if (![self paymentAuthorizationViewControllerCanMakePayments]) {
        return NO;
    }

    return YES;
#else
    return NO;
#endif
}

- (void)authorizeApplePay {
#if BT_ENABLE_APPLE_PAY
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

    if (self.client.configuration.applePayStatus == BTClientApplePayStatusOff) {
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


    UIViewController *paymentAuthorizationViewController = [self paymentAuthorizationViewControllerWithPaymentRequest:paymentRequest];
    if (paymentAuthorizationViewController == nil) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorInitialization
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize a Apple Pay authorization view controller. Check device, OS version, cards in Passbook and configuration." }];
        [self informDelegateDidFailWithError:error];
        return;
    }

    [self informDelegateRequestsPresentationOfViewController:paymentAuthorizationViewController];
#else
    NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                         code:BTPaymentProviderErrorInitialization
                                     userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not enabled in this build. Please use the Braintree/Apple-Pay CocoaPod subspec and ensure you have a BT_ENABLE_APPLE_PAY=1 preprocessor macro in your build settings." }];
    [self informDelegateDidFailWithError:error];
#if DEBUG
    @throw [NSException exceptionWithName:@"Apple Pay not enabled" reason:error.localizedDescription userInfo:nil];
#else
    [[BTLogger sharedLogger] error:error.localizedDescription];
#endif
#endif
}

#if BT_ENABLE_APPLE_PAY

- (UIViewController *)paymentAuthorizationViewControllerWithPaymentRequest:(PKPaymentRequest *)paymentRequest {
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
    }
    return paymentAuthorizationViewController;
}

- (PKPaymentRequest *)paymentRequest {
    if (![PKPaymentRequest class]) {
        return nil;
    }

    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.currencyCode = self.client.configuration.applePayCurrencyCode;
    paymentRequest.countryCode = self.client.configuration.applePayCountryCode;
    paymentRequest.merchantIdentifier = self.client.configuration.applePayMerchantIdentifier;
    paymentRequest.supportedNetworks = self.client.configuration.applePaySupportedNetworks;

    if (self.paymentSummaryItems) {
        paymentRequest.paymentSummaryItems = self.paymentSummaryItems;
    }

    if (self.requiredBillingAddressFields) {
        paymentRequest.requiredBillingAddressFields = self.requiredBillingAddressFields;
    }

    if (self.requiredShippingAddressFields) {
        paymentRequest.requiredShippingAddressFields = self.requiredShippingAddressFields;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.shippingAddress) {
        paymentRequest.shippingAddress = self.shippingAddress;
    }
    
    if (self.billingAddress) {
        paymentRequest.billingAddress = self.billingAddress;
    }
#pragma clang diagnostic pop
    
    if (self.shippingContact) {
        paymentRequest.shippingContact = self.shippingContact;
    }
    
    if (self.billingContact) {
        paymentRequest.billingContact = self.billingContact;
    }

    if (self.shippingMethods) {
        paymentRequest.shippingMethods = self.shippingMethods;
    }

    if (self.supportedNetworks) {
        paymentRequest.supportedNetworks = self.supportedNetworks;
    }

    return paymentRequest;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)setBillingAddress:(ABRecordRef)billingAddress {
    _billingAddress = CFRetain(billingAddress);
}

- (void)setShippingAddress:(ABRecordRef)shippingAddress {
    _shippingAddress = CFRetain(shippingAddress);
}

#pragma clang diagnostic pop

- (void)dealloc {
    if (_billingAddress) {
        CFRelease(_billingAddress);
    }

    if (_shippingAddress) {
        CFRelease(_shippingAddress);
    }
}
#endif

#pragma mark Internal Helpers - Exposed for Testing

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL)paymentAuthorizationViewControllerCanMakePayments {
#if BT_ENABLE_APPLE_PAY
    if (![PKPaymentAuthorizationViewController class]) {
        return NO;
    }
    if ([[self class] isSimulator]) {
        return [BTMockApplePayPaymentAuthorizationViewController canMakePayments];
    } else {
        return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.paymentRequest.supportedNetworks];
    }
#else
    return NO;
#endif
}

#pragma mark PKPaymentAuthorizationViewController Delegate

#if BT_ENABLE_APPLE_PAY
- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self applePayPaymentAuthorizationViewControllerDidAuthorizePayment:payment
                                                             completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self applePayPaymentAuthorizationViewControllerDidFinish:controller];
}
#endif

#pragma mark MockApplePayPaymentAuthorizationViewController Delegate

#if BT_ENABLE_APPLE_PAY
- (void)mockApplePayPaymentAuthorizationViewController:(__unused BTMockApplePayPaymentAuthorizationViewController *)viewController
                                   didAuthorizePayment:(PKPayment *)payment
                                            completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self applePayPaymentAuthorizationViewControllerDidAuthorizePayment:payment
                                                             completion:completion];
}

- (void)mockApplePayPaymentAuthorizationViewControllerDidFinish:(BTMockApplePayPaymentAuthorizationViewController *)viewController {
    [self applePayPaymentAuthorizationViewControllerDidFinish:viewController];
}
#endif

#pragma mark Payment Authorization

#if BT_ENABLE_APPLE_PAY
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
#endif

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
    [self.client postAnalyticsEvent:@"ios.apple-pay-provider.will-process"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillProcess:)]) {
        [self.delegate paymentMethodCreatorWillProcess:self];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.apple-pay-provider.start"];
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
