#import "BTPaymentFlowClient_Internal.h"
#import <SafariServices/SafariServices.h>

#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTPaymentFlowRequest.h>
#import <Braintree/BTPaymentFlowResult.h>
#import <Braintree/BTLogger_Internal.h>
#import <Braintree/BTAPIClient_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>
#import "../BraintreeCore/BTLogger_Internal.h"
#import "../BraintreeCore/BTAPIClient_Internal.h"

#else // Carthage
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>
#import <BraintreeCore/BTLogger_Internal.h>
#import <BraintreeCore/BTAPIClient_Internal.h>

#endif

@interface BTPaymentFlowClient () <SFSafariViewControllerDelegate>

@property (nonatomic, copy) void (^paymentFlowCompletionBlock)(BTPaymentFlowResult *, NSError *);
@property (nonatomic, strong, nullable) SFSafariViewController *safariViewController;
@property (nonatomic, strong, nullable) id<BTPaymentFlowRequestDelegate> paymentFlowRequestDelegate;
@property (nonatomic, copy, nonnull) NSString *returnURLScheme;
@property (nonatomic, strong, nonnull) BTAPIClient *apiClient;

@end

NSString * const BTPaymentFlowClientErrorDomain = @"com.braintreepayments.BTPaymentFlowClientErrorDomain";

@implementation BTPaymentFlowClient

static BTPaymentFlowClient *paymentFlowClient;

+ (void)load {
    if (self == [BTPaymentFlowClient class]) {
        [[BTAppContextSwitcher sharedInstance] registerAppContextSwitchClient:self];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
        _returnURLScheme = [BTAppContextSwitcher sharedInstance].returnURLScheme;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)startPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    [self setupPaymentFlow:request completion:completionBlock];
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.start-payment.selected", [self.paymentFlowRequestDelegate paymentFlowName]]];
    [self.paymentFlowRequestDelegate handleRequest:request client:self.apiClient paymentClientDelegate:self];
}

- (void)setupPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    paymentFlowClient = self;
    self.paymentFlowCompletionBlock = completionBlock;
    self.paymentFlowRequestDelegate = request;
}

- (void)performSwitchRequest:(NSURL *)appSwitchURL {
    [self informDelegatePresentingViewControllerRequestPresent:appSwitchURL];
}

- (void)informDelegatePresentingViewControllerRequestPresent:(NSURL *)appSwitchURL {
    if ([self.viewControllerPresentingDelegate respondsToSelector:@selector(paymentClient:requestsPresentationOfViewController:)]) {
        self.safariViewController = [[SFSafariViewController alloc] initWithURL:appSwitchURL];
        self.safariViewController.delegate = self;
        self.safariViewController.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleCancel;
        [self.viewControllerPresentingDelegate paymentClient:self requestsPresentationOfViewController:self.safariViewController];
    } else {
        [[BTLogger sharedLogger] critical:@"Unable to display View Controller to continue payment flow. BTPaymentFlowClient needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set."];
    }
}

- (void)informDelegatePresentingViewControllerNeedsDismissal {
    if (self.viewControllerPresentingDelegate != nil && [self.viewControllerPresentingDelegate respondsToSelector:@selector(paymentClient:requestsDismissalOfViewController:)]) {
        [self.viewControllerPresentingDelegate paymentClient:self requestsDismissalOfViewController:self.safariViewController];
        self.safariViewController = nil;
    } else {
        [[BTLogger sharedLogger] critical:@"Unable to dismiss View Controller to end payment flow. BTPaymentFlowClient needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set."];
    }
}

#pragma mark - App switch

+ (void)handleReturnURL:(NSURL *)url {
    [paymentFlowClient handleOpenURL:url];
}

+ (BOOL)canHandleReturnURL:(NSURL *)url {
    return [paymentFlowClient.paymentFlowRequestDelegate canHandleAppSwitchReturnURL:url];
}

- (void)handleOpenURL:(NSURL *)url {
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];
    if (self.safariViewController) {
        [self informDelegatePresentingViewControllerNeedsDismissal];
    }
    [self.paymentFlowRequestDelegate handleOpenURL:url];
}

- (void)safariViewControllerDidFinish:(__unused SFSafariViewController *)controller {
    [self onPaymentCancel];
}

#pragma mark - BTPaymentFlowClientDelegate protocol

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
    NSError *error = [NSError errorWithDomain:BTPaymentFlowClientErrorDomain
                                         code:BTPaymentFlowClientErrorTypeCanceled
                                     userInfo:@{NSLocalizedDescriptionKey: @"Payment flow was canceled by the user."}];
    self.paymentFlowCompletionBlock(nil, error);
    paymentFlowClient = nil;
}

- (void)onPaymentComplete:(BTPaymentFlowResult *)result error:(NSError *)error {
    self.paymentFlowCompletionBlock(result, error);
    paymentFlowClient = nil;
}

@end
