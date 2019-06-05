#if __has_include("BTLogger_Internal.h")
#import "BTLogger_Internal.h"
#else
#import <BraintreeCore/BTLogger_Internal.h>
#endif
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import "BTPaymentFlowDriver_Internal.h"
#import "Braintree-Version.h"
#import <SafariServices/SafariServices.h>

@interface BTPaymentFlowDriver () <SFSafariViewControllerDelegate>

@property (nonatomic, copy) void (^paymentFlowCompletionBlock)(BTPaymentFlowResult *, NSError *);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
@property (nonatomic, strong, nullable) SFSafariViewController *safariViewController NS_AVAILABLE_IOS(9_0);
#endif
@property (nonatomic, strong, nullable) id<BTPaymentFlowRequestDelegate> paymentFlowRequestDelegate;

@end

NSString * const BTPaymentFlowDriverErrorDomain = @"com.braintreepayments.BTPaymentFlowDriverErrorDomain";

@implementation BTPaymentFlowDriver

static BTPaymentFlowDriver *paymentFlowDriver;

+ (void)load {
    if (self == [BTPaymentFlowDriver class]) {
        [[BTAppSwitch sharedInstance] registerAppSwitchHandler:self];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

#pragma mark - Accessors

- (id)application {
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

- (NSBundle *)bundle {
    if (!_bundle) {
        _bundle = [NSBundle mainBundle];
    }
    return _bundle;
}

- (NSString *)returnURLScheme {
    if (!_returnURLScheme) {
        _returnURLScheme = [BTAppSwitch sharedInstance].returnURLScheme;
    }
    return _returnURLScheme;
}

- (void)startPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    [self setupPaymentFlow:request completion:completionBlock];
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.start-payment.selected", [self.paymentFlowRequestDelegate paymentFlowName]]];
    [self.paymentFlowRequestDelegate handleRequest:request client:self.apiClient paymentDriverDelegate:self];
}

- (void)setupPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    paymentFlowDriver = self;
    self.paymentFlowCompletionBlock = completionBlock;
    self.paymentFlowRequestDelegate = request;
}

- (void)performSwitchRequest:(NSURL *)appSwitchURL {
    [self informDelegateAppContextWillSwitch];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 9.0, *)) {
#else
    if ([SFSafariViewController class]) {
#endif
        [self informDelegatePresentingViewControllerRequestPresent:appSwitchURL];
    } else {
        UIApplication *application = [UIApplication sharedApplication];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 10.0, *)) {
#else
            if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
#endif
            [application openURL:appSwitchURL options:[NSDictionary dictionary] completionHandler:nil];
            return;
        }
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [application openURL:appSwitchURL];
#pragma clang diagnostic pop
    }
}

- (void)informDelegatePresentingViewControllerRequestPresent:(NSURL *)appSwitchURL {
    if ([self.viewControllerPresentingDelegate respondsToSelector:@selector(paymentDriver:requestsPresentationOfViewController:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 9.0, *)) {
#endif
            self.safariViewController = [[SFSafariViewController alloc] initWithURL:appSwitchURL];
            self.safariViewController.delegate = self;
            [self.viewControllerPresentingDelegate paymentDriver:self requestsPresentationOfViewController:self.safariViewController];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        }
#endif
    } else {
        [[BTLogger sharedLogger] critical:@"Unable to display View Controller to continue payment flow. BTPaymentFlowDriver needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set."];
    }
}

- (void)informDelegatePresentingViewControllerNeedsDismissal {
    if (self.viewControllerPresentingDelegate != nil && [self.viewControllerPresentingDelegate respondsToSelector:@selector(paymentDriver:requestsDismissalOfViewController:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 9.0, *)) {
#endif
            [self.viewControllerPresentingDelegate paymentDriver:self requestsDismissalOfViewController:self.safariViewController];
            self.safariViewController = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        }
#endif
    } else {
        [[BTLogger sharedLogger] critical:@"Unable to dismiss View Controller to end payment flow. BTPaymentFlowDriver needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set."];
    }
}

#pragma mark - App switch

+ (void)handleAppSwitchReturnURL:(NSURL *)url {
    [paymentFlowDriver handleOpenURL:url];
}

+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [paymentFlowDriver.paymentFlowRequestDelegate canHandleAppSwitchReturnURL:url sourceApplication:sourceApplication];
}

- (void)handleOpenURL:(NSURL *)url {
    [self informDelegateAppContextDidReturn];
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 9.0, *)) {
#endif
        if (self.safariViewController) {
            [self informDelegatePresentingViewControllerNeedsDismissal];
        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    }
#endif
    [self.paymentFlowRequestDelegate handleOpenURL:url];
}

- (void)safariViewControllerDidFinish:(__unused SFSafariViewController *)controller API_AVAILABLE(ios(9.0)) {
    [self onPaymentCancel];
}

#pragma mark - BTPaymentFlowDriverDelegate protocol

- (void)onPaymentWithURL:(NSURL *)url error:(NSError *)error {
    if (error) {
        [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.start-payment.failed", [self.paymentFlowRequestDelegate paymentFlowName]]];
        [self onPaymentComplete:nil error:error];
        return;
    }
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.initiate.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];

    [self performSwitchRequest:url];
}

- (void)onPaymentCancel {
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.canceled", [self.paymentFlowRequestDelegate paymentFlowName]]];
    NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                         code:BTPaymentFlowDriverErrorTypeCanceled
                                     userInfo:@{NSLocalizedDescriptionKey: @"Payment flow was canceled by the user."}];
    self.paymentFlowCompletionBlock(nil, error);
    paymentFlowDriver = nil;
}

- (void)onPaymentComplete:(BTPaymentFlowResult *)result error:(NSError *)error {
    self.paymentFlowCompletionBlock(result, error);
    paymentFlowDriver = nil;
}

- (void)informDelegateAppContextWillSwitch {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppContextWillSwitchNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.appSwitchDelegate respondsToSelector:@selector(appContextWillSwitch:)]) {
        [self.appSwitchDelegate appContextWillSwitch:self];
    }
}

- (void)informDelegateAppContextDidReturn {
    NSNotification *notification = [[NSNotification alloc] initWithName:BTAppContextDidReturnNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([self.appSwitchDelegate respondsToSelector:@selector(appContextDidReturn:)]) {
        [self.appSwitchDelegate appContextDidReturn:self];
    }
}

@end

