#import <Foundation/Foundation.h>

@protocol BTViewControllerPresentingDelegate;

@class BTAPIClient;
@class BTPaymentFlowRequest;
@class BTPaymentFlowResult;

NS_ASSUME_NONNULL_BEGIN

/**
 Payment flow error domain
 */
extern NSString * const BTPaymentFlowErrorDomain;

/**
 Errors associated with payment flows.
 */
typedef NS_ENUM(NSInteger, BTPaymentFlowErrorType) {
    /// PaymentFlow unknown error.
    BTPaymentFlowErrorTypeUnknown = 0,
    
    /// PaymentFlow is disabled in configuration.
    BTPaymentFlowErrorTypeDisabled,
    
    /// UIApplication failed to switch to browser.
    BTPaymentFlowErrorTypeAppSwitchFailed,
    
    /// Return URL was invalid.
    BTPaymentFlowErrorTypeInvalidReturnURL,
    
    /// Braintree SDK is integrated incorrectly.
    BTPaymentFlowErrorTypeIntegration,

    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    BTPaymentFlowErrorTypeCanceled,
};

/**
 Protocol for payment flow processing via BTPaymentFlowRequestDelegate.
 */
@protocol BTPaymentFlowClientDelegate

/**
 Use when payment URL is ready for processing.
 */
- (void)onPaymentWithURL:(NSURL * _Nullable) url error:(NSError * _Nullable)error;

/**
 Use when the payment flow was canceled.
 */
//- (void)onPaymentCancel;

/**
 Use when the payment flow has completed or encountered an error.
 @param result The BTPaymentFlowResult of the payment flow.
 @param error NSError containing details of the error.
 */
- (void)onPaymentComplete:(BTPaymentFlowResult * _Nullable)result error:(NSError * _Nullable)error;

/**
 Returns the base return URL scheme used by the client.
 @return A NSString representing the base return URL scheme used by the client.
 */
- (NSString *)returnURLScheme;

/**
 Returns the BTAPIClient used by the BTPaymentFlowClientDelegate.
 @return The BTAPIClient used by the client.
 */
- (BTAPIClient *)apiClient;

@end

/**
 Protocol for payment flow processing.
 */
// TODO: do we need this still?
@protocol BTPaymentFlowRequestDelegate

/**
 Handle payment request for a variety of web/app switch flows.
 
 Use the delegate to handle success/error/cancel flows.
 
 @param request A BTPaymentFlowRequest request.
 @param delegate The BTPaymentFlowClientDelegate to handle response.
 */
- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentClientDelegate:(id<BTPaymentFlowClientDelegate>)delegate;

/**
 Check if this BTPaymentFlowRequestDelegate can handle the return URL
 
 @param url The URL to check.
 @return True if the BTPaymentFlowRequestDelegate can handle the URL. Otherwise return false.
 */
//- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url;

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
 BTPaymentFlowClient handles the shared aspects of web/app payment flows.
 
 Handles the app switching and shared logic for payment flows that use web or app switching.
 */
@interface BTPaymentFlowClient : NSObject <BTPaymentFlowClientDelegate>

/**
 Initialize a new BTPaymentFlowClient instance.
 
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
// TODO: do we need this still?
//@property (nonatomic, weak, nullable) id<BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;

/**
 :nodoc: Exposed for testing
*/
+ (void)handleReturnURL:(NSURL * _Nonnull)url NS_SWIFT_NAME(handleReturnURL(_:));

/**
 :nodoc: Exposed for testing
*/
+ (BOOL)canHandleReturnURL:(NSURL * _Nonnull)url NS_SWIFT_NAME(canHandleReturnURL(_:));

@end

NS_ASSUME_NONNULL_END
