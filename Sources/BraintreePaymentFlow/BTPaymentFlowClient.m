#import "BTPaymentFlowClient_Internal.h"
#import <AuthenticationServices/AuthenticationServices.h>

// MARK: - Objective-C File Imports for Package Managers
#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTPaymentFlowRequest.h>
#import <Braintree/BTPaymentFlowResult.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>

#else // Carthage
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>

#endif

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

@interface BTPaymentFlowClient () <ASWebAuthenticationPresentationContextProviding>

@property (nonatomic, copy) void (^paymentFlowCompletionBlock)(BTPaymentFlowResult *, NSError *);
@property (nonatomic, strong, nullable) id<BTPaymentFlowRequestDelegate> paymentFlowRequestDelegate;
@property (nonatomic, copy, nonnull) NSString *returnURLScheme;
@property (nonatomic, strong, nonnull) BTAPIClient *apiClient;
@property (nonatomic, strong, nonnull) BTPaymentFlowRequest *request;

@end

NSString * const BTPaymentFlowErrorDomain = @"com.braintreepayments.BTPaymentFlowErrorDomain";

@implementation BTPaymentFlowClient

static BTPaymentFlowClient *paymentFlowClient;

// TODO: remove?
//+ (void)load {
//    if (self == [BTPaymentFlowClient class]) {
//        [[BTAppContextSwitcher sharedInstance] registerAppContextSwitchClient:self];
//    }
//}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
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
    self.request = request;
    self.paymentFlowCompletionBlock = completionBlock;
    self.paymentFlowRequestDelegate = request;
}

#pragma mark - BTPaymentFlowClientDelegate protocol

- (void)onPaymentWithURL:(NSURL *)url error:(NSError *)error {
    if (error) {
        [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.start-payment.failed", [self.paymentFlowRequestDelegate paymentFlowName]]];
        [self onPaymentComplete:nil error:error];
        return;
    }
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.initiate.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];

    self.authenticationSession = [[ASWebAuthenticationSession alloc] initWithURL:url
                                                               callbackURLScheme:BTCoreConstants.callbackURLScheme
                                                               completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        // Required to avoid memory leak for BTPaymentFlowClient
        self.authenticationSession = nil;

        if (error) {
            if (error.domain == ASWebAuthenticationSessionErrorDomain && error.code == ASWebAuthenticationSessionErrorCodeCanceledLogin) {
                NSString *eventName = [NSString stringWithFormat:@"ios.%@.authsession.browser.cancel", [self.paymentFlowRequestDelegate paymentFlowName]];
                [self.apiClient sendAnalyticsEvent:eventName];
            }

            [self onPaymentComplete:nil error:error];
            return;
        }

        [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.%@.webswitch.succeeded", [self.paymentFlowRequestDelegate paymentFlowName]]];
        [self.paymentFlowRequestDelegate handleOpenURL:callbackURL];
    }];

    self.authenticationSession.presentationContextProvider = self;
    [self.authenticationSession start];
}

- (void)onPaymentComplete:(BTPaymentFlowResult *)result error:(NSError *)error {
        self.paymentFlowCompletionBlock(result, error);
        paymentFlowClient = nil;
    }

#pragma mark - ASWebAuthenticationPresentationContextProviding protocol

// NEXT_MAJOR_VERSION (v7): move this protocol conformance to an extension on BTPaymentFlowClient
- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session API_AVAILABLE(ios(13)) NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
    for (UIScene* scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            return windowScene.windows.firstObject;
        }
    }

    if (@available(iOS 15, *)) {
        return ((UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject).windows.firstObject;
    } else {
        return UIApplication.sharedApplication.windows.firstObject;
    }
}

@end
