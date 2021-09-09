#import "BTPaymentFlowDriver_Internal.h"

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

@interface BTPaymentFlowDriver () <ASWebAuthenticationPresentationContextProviding>

@property (nonatomic, copy) void (^paymentFlowCompletionBlock)(BTPaymentFlowResult *, NSError *);
@property (nonatomic, strong, nullable) id<BTPaymentFlowRequestDelegate> paymentFlowRequestDelegate;
@property (nonatomic, copy, nonnull) NSString *returnURLScheme;
@property (nonatomic, strong, nonnull) BTAPIClient *apiClient;
@property (nonatomic, strong, nonnull) BTPaymentFlowRequest *request;

@end

NSString *const BTPaymentFlowDriverErrorDomain = @"com.braintreepayments.BTPaymentFlowDriverErrorDomain";
NSString *const BTCallbackURLScheme = @"sdk.ios.braintree";

@implementation BTPaymentFlowDriver

static BTPaymentFlowDriver *paymentFlowDriver;

+ (void)load {
    if (self == [BTPaymentFlowDriver class]) {
        [[BTAppContextSwitcher sharedInstance] registerAppContextSwitchDriver:self];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
        _returnURLScheme = BTCallbackURLScheme;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)startPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    [self setupPaymentFlow:request completion:completionBlock];
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.start-payment.selected", [self.paymentFlowRequestDelegate paymentFlowName]]];
    [self.paymentFlowRequestDelegate handleRequest:request client:self.apiClient paymentDriverDelegate:self];
}

- (void)setupPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    paymentFlowDriver = self;
    self.request = request;
    self.paymentFlowCompletionBlock = completionBlock;
    self.paymentFlowRequestDelegate = request;
}

#pragma mark - BTPaymentFlowDriverDelegate protocol

- (void)onPaymentWithURL:(NSURL *)url error:(NSError *)error {
    if (error) {
        [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.start-payment.failed", [self.paymentFlowRequestDelegate paymentFlowName]]];
        [self onPaymentComplete:nil error:error];
        return;
    }
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.initiate.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];

    self.authenticationSession = [[ASWebAuthenticationSession alloc] initWithURL:url callbackURLScheme:BTCallbackURLScheme completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        // Required to avoid memory leak for BTPaymentFlowDriver
        self.authenticationSession = nil;

        if (error) {
            if (error.domain == ASWebAuthenticationSessionErrorDomain && error.code == ASWebAuthenticationSessionErrorCodeCanceledLogin) {
                [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.canceled", [self.paymentFlowRequestDelegate paymentFlowName]]];
            }
            NSError *err = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                               code:BTPaymentFlowDriverErrorTypeCanceled
                                           userInfo:@{NSLocalizedDescriptionKey: @"Payment flow was canceled by the user."}];
            self.paymentFlowCompletionBlock(nil, err);
            paymentFlowDriver = nil;
            return;
        }

        [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];

        [self.paymentFlowRequestDelegate handleOpenURL:callbackURL];
    }];

    if (@available(iOS 13, *)) {
        self.authenticationSession.presentationContextProvider = self;
    }

    [self.authenticationSession start]; // TODO what if the start fails
}

- (void)onPaymentComplete:(BTPaymentFlowResult *)result error:(NSError *)error {
    self.paymentFlowCompletionBlock(result, error);
    paymentFlowDriver = nil;
}

#pragma mark - ASWebAuthenticationPresentationContextProviding protocol

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session API_AVAILABLE(ios(13)) {
    if (self.request.activeWindow) {
        return self.request.activeWindow;
    }

    for (UIScene* scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            return windowScene.windows.firstObject;
        }
    }
    return UIApplication.sharedApplication.windows.firstObject;
}

@end
