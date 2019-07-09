#import "BTPaymentFlowDriver.h"

@interface BTPaymentFlowDriver ()

/**
 Defaults to [UIApplication sharedApplication], but exposed for unit tests to inject test doubles
 to prevent calls to openURL. Its type is `id` and not `UIApplication` because trying to subclass
 UIApplication is not possible, since it enforces that only one instance can ever exist
 */
@property (nonatomic, strong) id _Nonnull application;

/**
 Defaults to [NSBundle mainBundle], but exposed for unit tests to inject test doubles to stub values in infoDictionary
 */
@property (nonatomic, strong) NSBundle * _Nonnull bundle;

/**
 Defaults to use [BTAppSwitchHandler sharedInstance].returnURLScheme, but exposed for unit tests to stub returnURLScheme.
 */
@property (nonatomic, copy) NSString * _Nonnull returnURLScheme;

/**
 Exposed for testing to get the instance of BTAPIClient after it has been copied by `copyWithSource:integration:`
 */
@property (nonatomic, strong) BTAPIClient * _Nonnull apiClient;

/**
 Set up the BTPaymentFlowDriver with a request object and a completion block without starting the flow.

 @param request A BTPaymentFlowRequest to set on the BTPaymentFlow
 @param completionBlock This completion will be invoked exactly once when the payment flow is complete or an error occurs.
 */
- (void)setupPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *_Nonnull)request completion:(void (^_Nullable)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock;

@end
