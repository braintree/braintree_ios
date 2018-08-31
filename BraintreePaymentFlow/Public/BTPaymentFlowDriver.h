#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowResult.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Payment flow error domain
 */
extern NSString * const BTPaymentFlowDriverErrorDomain;

/**
 Errors associated with payment flows.
 */
typedef NS_ENUM(NSInteger, BTPaymentFlowDriverErrorType) {
    /// PaymentFlow unknown error.
    BTPaymentFlowDriverErrorTypeUnknown = 0,
    
    /// PaymentFlow is disabled in configuration.
    BTPaymentFlowDriverErrorTypeDisabled,
    
    /// UIApplication failed to switch to browser.
    BTPaymentFlowDriverErrorTypeAppSwitchFailed,
    
    /// Return URL was invalid.
    BTPaymentFlowDriverErrorTypeInvalidReturnURL,
    
    /// Braintree SDK is integrated incorrectly.
    BTPaymentFlowDriverErrorTypeIntegration,
    
    /// Request URL was invalid, configuration may be missing required values.
    BTPaymentFlowDriverErrorTypeInvalidRequestURL,

    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    BTPaymentFlowDriverErrorTypeCanceled,
};

/**
 Protocol for payment flow processing via BTPaymentFlowRequestDelegate.
 */
@protocol BTPaymentFlowDriverDelegate

/**
 Use when payment URL is ready for processing.
 */
- (void)onPaymentWithURL:(NSURL * _Nullable) url error:(NSError * _Nullable)error;

/**
 Use when the payment flow was cancelled.
 */
- (void)onPaymentCancel;

/**
 Use when the payment flow has completed or encountered an error.
 @param result The BTPaymentFlowResult of the payment flow.
 @param error NSError containing details of the error.
 */
- (void)onPaymentComplete:(BTPaymentFlowResult * _Nullable)result error:(NSError * _Nullable)error;

/**
 Returns the base return URL scheme used by the driver.
 @return A NSString representing the base return URL scheme used by the driver.
 */
- (NSString *)returnURLScheme;

/**
 Returns the BTAPIClient used by the BTPaymentFlowDriverDelegate.
 @return The BTAPIClient used by the driver.
 */
- (BTAPIClient *)apiClient;

@end

/**
 Protocol for payment flow processing.
 */
@protocol BTPaymentFlowRequestDelegate

/**
 Handle payment request for a variety of web/app switch flows.
 
 Use the delegate to handle success/error/cancel flows.
 
 @param request A BTPaymentFlowRequest request.
 @param delegate The BTPaymentFlowDriverDelegate to handle response.
 */
- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate;

/**
 Check if this BTPaymentFlowRequestDelegate can handle the URL from the source application.
 
 @param url The URL to check.
 @param sourceApplication The source application to sent the URL.
 @return True if the BTPaymentFlowRequestDelegate can handle the URL. Otherwise return false.
 */
- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/**
 Handles the return URL and completes and post processing.
 
 @param url The URL to check.
 */
- (void)handleOpenURL:(NSURL *)url;

/**
 A short and unique alphanumeric name for the payment flow.
 
 Used for analytics/events. No spaces and all lowercase.
 */
- (NSString *)paymentFlowName;

@end

/**
 BTPaymentFlowDriver handles the shared aspects of web/app payment flows.
 
 Handles the app switching and shared logic for payment flows that use web or app switching.
 */
@interface BTPaymentFlowDriver : NSObject <BTAppSwitchHandler, BTPaymentFlowDriverDelegate>

/**
 Initialize a new BTPaymentFlowDriver instance.
 
 @param apiClient The API client.
 */
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).

 @param request A BTPaymentFlowRequest request.
 @param completionBlock This completion will be invoked exactly once when the payment flow is complete or an error occurs.
 */
- (void)startPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)( BTPaymentFlowResult * _Nullable result,  NSError * _Nullable error))completionBlock;

/**
 A required delegate to control the presentation and dismissal of view controllers.
 */
@property (nonatomic, weak, nullable) id<BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;

/**
 An optional delegate for receiving notifications about the lifecycle of a payment flow app/browser switch, as well as updating your UI

 @note BTPaymentFlowDriver will only send notifications for `appContextWillSwitch:` and `appContextDidReturn:`.
 */
@property (nonatomic, weak, nullable) id<BTAppSwitchDelegate> appSwitchDelegate;

@end

NS_ASSUME_NONNULL_END
