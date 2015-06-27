@import PassKit;

#import "BTPaymentProvider.h"
#import "BTClient_Internal.h"
#import "BTAppSwitching.h"

#import "BTVenmoAppSwitchHandler.h"

#import "BTPayPalAppSwitchHandler.h"
#import "BTPaymentApplePayProvider.h"
#import "BTLogger_Internal.h"
#import "BTCoinbase.h"


@interface BTPaymentProvider () <BTAppSwitchingDelegate, BTPaymentMethodCreationDelegate>
@property (nonatomic, strong) BTPaymentApplePayProvider *applePayPaymentProvider;
@end

@implementation BTPaymentProvider

- (instancetype)initWithClient:(BTClient *)client {
    self = [super init];
    if (self) {
        self.client = client;
    }
    return self;
}

- (BTPaymentApplePayProvider *)applePayPaymentProvider {
    if (!_applePayPaymentProvider) {
        _applePayPaymentProvider = [[BTPaymentApplePayProvider alloc] initWithClient:self.client];
        _applePayPaymentProvider.delegate = self;
    }
    return _applePayPaymentProvider;
}

- (void)createPaymentMethod:(BTPaymentProviderType)type {
    [self createPaymentMethod:type options:BTPaymentAuthorizationOptionMechanismAny];
}

- (void)createPaymentMethod:(BTPaymentProviderType)type options:(BTPaymentMethodCreationOptions)options {
    [self setStatus:BTPaymentProviderStatusInitialized];

    switch (type) {
        case BTPaymentProviderTypePayPal:
            [self authorizePayPal:options];
            break;
        case BTPaymentProviderTypeVenmo:
            [self authorizeVenmo:options];
            break;
        case BTPaymentProviderTypeApplePay:
            [self authorizeApplePay:options];
            break;
        case BTPaymentProviderTypeCoinbase:
            [self authorizeCoinbase];
            break;
        default:
            break;
    }
}

- (BOOL)canCreatePaymentMethodWithProviderType:(BTPaymentProviderType)type {
    switch (type) {
        case BTPaymentProviderTypeApplePay:
            return [self.applePayPaymentProvider canAuthorizeApplePayPayment];
        case BTPaymentProviderTypePayPal:
            return [[BTPayPalAppSwitchHandler sharedHandler] appSwitchAvailableForClient:self.client];
        case BTPaymentProviderTypeVenmo:
            return [[BTVenmoAppSwitchHandler sharedHandler] appSwitchAvailableForClient:self.client];
        case BTPaymentProviderTypeCoinbase:
            return [[BTCoinbase sharedCoinbase] appSwitchAvailableForClient:self.client];
        default:
            return NO;
    }
}


#pragma mark Apple Pay

- (void)authorizeApplePay:(BTPaymentMethodCreationOptions)options {
    if ((options & BTPaymentAuthorizationOptionMechanismViewController) == 0) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorOptionNotSupported
                                         userInfo:@{NSLocalizedDescriptionKey: @"Apple Pay requires option BTPaymentAuthorizationOptionMechanismViewController"}];
        [self informDelegateDidFailWithError:error andPostAnalyticsEvent:NO];
        return;
    }

    [self.applePayPaymentProvider authorizeApplePay];
}

#pragma mark Venmo

- (void)authorizeVenmo:(BTPaymentMethodCreationOptions)options {

    if ((options & BTPaymentAuthorizationOptionMechanismAppSwitch) == 0) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain code:BTPaymentProviderErrorOptionNotSupported userInfo:nil];
        [self informDelegateDidFailWithError:error andPostAnalyticsEvent:NO];
        return;
    }

    NSError *error;
    BOOL appSwitchSuccess = [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self error:&error];
    if (appSwitchSuccess) {
        [self informDelegateWillPerformAppSwitch];
    } else {
        if (!error) {
            error = [NSError errorWithDomain:BTPaymentProviderErrorDomain code:BTPaymentProviderErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"App Switch did not initiate, but did not return an error"}];
        }
        [self informDelegateDidFailWithError:error andPostAnalyticsEvent:YES];
    }
}

#pragma mark PayPal

- (void)authorizePayPal:(BTPaymentMethodCreationOptions)options {
    
    BOOL appSwitchOptionEnabled = (options & BTPaymentAuthorizationOptionMechanismAppSwitch) == BTPaymentAuthorizationOptionMechanismAppSwitch;

    if (!appSwitchOptionEnabled) {
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain
                                             code:BTPaymentProviderErrorOptionNotSupported
                                         userInfo:@{ NSLocalizedDescriptionKey: @"At least BTPaymentAuthorizationOptionMechanismAppSwitch must be enabled in options to start PayPal" }];
        [self informDelegateDidFailWithError:error andPostAnalyticsEvent:NO];
        return;
    }
    
    NSError *error;
    
    BOOL appSwitchSuccess = [[BTPayPalAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self error:&error];
    if (appSwitchSuccess) {
        [self informDelegateWillPerformAppSwitch];
    } else {
        NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey: @"PayPal authorization failed" } mutableCopy];
        if (error != nil) {
            userInfo[NSUnderlyingErrorKey] = error;
        }
        NSError *error = [NSError errorWithDomain:BTPaymentProviderErrorDomain code:BTPaymentProviderErrorUnknown userInfo:userInfo];
        [self informDelegateDidFailWithError:error andPostAnalyticsEvent:YES];
    }
}


#pragma mark Coinbase

- (void)authorizeCoinbase {
    NSError *error;
    BOOL appSwitchSuccess = [[BTCoinbase sharedCoinbase] initiateAppSwitchWithClient:self.client delegate:self error:&error];
    if (appSwitchSuccess) {
        [self informDelegateWillPerformAppSwitch];
    } else {
        [self informDelegateDidFailWithError:error andPostAnalyticsEvent:YES];
    }
}


#pragma mark Inform Delegate

- (void)informDelegateWillPerformAppSwitch {
    [self.client postAnalyticsEvent:@"ios.authorizer.will-app-switch"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillPerformAppSwitch:)]) {
        [self.delegate paymentMethodCreatorWillPerformAppSwitch:self];
    }
}

- (void)informDelegateWillProcess {
    [self setStatus:BTPaymentProviderStatusProcessing];

    [self.client postAnalyticsEvent:@"ios.authorizer.will-process-authorization-response"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillProcess:)]) {
        [self.delegate paymentMethodCreatorWillProcess:self];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.authorizer.requests-authorization-with-view-controller"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsPresentationOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.authorizer.requests-dismissal-of-authorization-view-controller"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsDismissalOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsDismissalOfViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self setStatus:BTPaymentProviderStatusSuccess];

    [self.client postAnalyticsEvent:@"ios.authorizer.did-create-payment-method"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didCreatePaymentMethod:)]) {
        [self.delegate paymentMethodCreator:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error andPostAnalyticsEvent:(BOOL)postAnalyticsEvent {
    [self setStatus:BTPaymentProviderStatusError];

    if (postAnalyticsEvent) {
        [self.client postAnalyticsEvent:@"ios.authorizer.did-fail-with-error"];
    }

    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    [self setStatus:BTPaymentProviderStatusCanceled];

    [self.client postAnalyticsEvent:@"ios.authorizer.did-cancel"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorDidCancel:)]) {
        [self.delegate paymentMethodCreatorDidCancel:self];
    }
}

#pragma mark BTAppSwitchingDelegate

- (void)appSwitcherWillCreatePaymentMethod:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateWillProcess];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self informDelegateDidCreatePaymentMethod:paymentMethod];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    [self informDelegateDidFailWithError:error andPostAnalyticsEvent:YES];
}

- (void)appSwitcherDidCancel:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateDidCancel];
}

#pragma mark BTPaymentMethodCreationDelegate

- (void)paymentMethodCreator:(__unused id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    [self informDelegateRequestsPresentationOfViewController:viewController];
}

- (void)paymentMethodCreator:(__unused id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(__unused id)sender {
    [self informDelegateWillPerformAppSwitch];
}

- (void)paymentMethodCreatorWillProcess:(__unused id)sender {
    [self informDelegateWillProcess];
}

- (void)paymentMethodCreatorDidCancel:(__unused id)sender {
    [self informDelegateDidCancel];
}

- (void)paymentMethodCreator:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self informDelegateDidCreatePaymentMethod:paymentMethod];
}

- (void)paymentMethodCreator:(__unused id)sender didFailWithError:(NSError *)error {
    [self informDelegateDidFailWithError:error andPostAnalyticsEvent:YES];
}

#if BT_ENABLE_APPLE_PAY

#pragma mark Payment Request Details

- (void)setPaymentSummaryItems:(NSArray *)paymentSummaryItems {
    _paymentSummaryItems = paymentSummaryItems;
    self.applePayPaymentProvider.paymentSummaryItems = paymentSummaryItems;
}

- (void)setRequiredBillingAddressFields:(PKAddressField)requiredBillingAddressFields {
    _requiredBillingAddressFields = requiredBillingAddressFields;
    self.applePayPaymentProvider.requiredBillingAddressFields = requiredBillingAddressFields;
}

- (void)setRequiredShippingAddressFields:(PKAddressField)requiredShippingAddressFields {
    _requiredShippingAddressFields = requiredShippingAddressFields;
    self.applePayPaymentProvider.requiredShippingAddressFields = requiredShippingAddressFields;
    ;
}

- (void)setBillingAddress:(ABRecordRef)billingAddress {
    _billingAddress = CFRetain(billingAddress);
    self.applePayPaymentProvider.billingAddress = billingAddress;
}

- (void)setShippingAddress:(ABRecordRef)shippingAddress {
    _shippingAddress = CFRetain(shippingAddress);
    self.applePayPaymentProvider.shippingAddress = shippingAddress;
}

- (void)setShippingMethods:(NSArray *)shippingMethods {
    _shippingMethods = shippingMethods;
    self.applePayPaymentProvider.shippingMethods = shippingMethods;
}

- (void)setSupportedNetworks:(NSArray *)supportedNetworks {
    _supportedNetworks = supportedNetworks;
    self.applePayPaymentProvider.supportedNetworks = supportedNetworks;
}

- (void)dealloc {
    if (_shippingAddress) {
        CFRelease(_shippingAddress);
    }

    if (_billingAddress) {
        CFRelease(_billingAddress);
    }
}

#endif

@end
