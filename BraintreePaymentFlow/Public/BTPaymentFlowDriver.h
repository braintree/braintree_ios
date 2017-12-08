#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTIdealBank.h"
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowResult.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTPaymentFlowDriverErrorDomain;

typedef NS_ENUM(NSInteger, BTPaymentFlowDriverErrorType) {
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
 @brief Protocol for payment flow processing via BTPaymentFlowRequestDelegate.
 */
@protocol BTPaymentFlowDriverDelegate

/**
 @brief Use when payment URL is ready for processing.
 */
- (void)onPaymentWithURL:(NSURL * _Nullable) url error:(NSError * _Nullable)error;

/**
 @brief Use when the payment flow was cancelled.
 */
- (void)onPaymentCancel;

/**
 @brief Use when the payment flow has completed or encountered an error.
 @param result The BTPaymentFlowResult of the payment flow.
 @param error NSError containing details of the error.
 */
- (void)onPaymentComplete:(BTPaymentFlowResult * _Nullable)result error:(NSError * _Nullable)error;

/**
 @brief Returns the base return URL scheme used by the driver.
 @return A NSString representing the base return URL scheme used by the driver.
 */
- (NSString *)returnURLScheme;

/**
 @brief Returns the BTAPIClient used by the BTPaymentFlowDriverDelegate.
 @return The BTAPIClient used by the driver.
 */
- (BTAPIClient *)apiClient;

@end

/**
 @brief Protocol for payment flow processing.
 */
@protocol BTPaymentFlowRequestDelegate

/**
 @brief Handle payment request for a variety of web/app switch flows.
 
 @discussion Use the delegate to handle success/error/cancel flows.
 
 @param request A BTPaymentFlowRequest request.
 @param delegate The BTPaymentFlowDriverDelegate to handle response.
 */
- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate;

/**
 @brief Check if this BTPaymentFlowRequestDelegate can handle the URL from the source application.
 
 @param url The URL to check.
 @param sourceApplication The source application to sent the URL.
 @return True if the BTPaymentFlowRequestDelegate can handle the URL. Otherwise return false.
 */
- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/**
 @brief Handles the return URL and completes and post processing.
 
 @param url The URL to check.
 */
- (void)handleOpenURL:(NSURL *)url;

/**
 @brief A short and unique alphanumeric name for the payment flow.
 
 @discussion Used for analytics/events. No spaces and all lowercase.
 */
- (NSString *)paymentFlowName;

@end

/**
 @brief BTPaymentFlowDriver handles the shared aspects of web/app payment flows.
 
 @discussion Handles the app switching and shared logic for payment flows that use web or app switching.
 */
@interface BTPaymentFlowDriver : NSObject <BTAppSwitchHandler, BTPaymentFlowDriverDelegate>

/**
 @brief Initialize a new BTPaymentFlowDriver instance.
 
 @param apiClient The API client.
 */
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 @brief Starts a payment flow using a BTPaymentFlowRequest (usually subclassed for specific payment methods).

 @param request A BTPaymentFlowRequest request.
 @param completionBlock This completion will be invoked exactly once when the payment flow is complete or an error occurs.
 */
- (void)startPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)( BTPaymentFlowResult * _Nullable result,  NSError * _Nullable error))completionBlock;

/**
 @brief A required delegate to control the presentation and dismissal of view controllers.
 */
@property (nonatomic, weak, nullable) id<BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;

@end

NS_ASSUME_NONNULL_END
