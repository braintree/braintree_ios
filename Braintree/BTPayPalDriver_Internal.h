#import "BTAnalyticsClient.h"
#import "BTPayPalDriver.h"
#import "BTPayPalRequestFactory.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTPayPalDriver ()

/// Set up the callback to be invoked on return from browser or app switch for PayPal Checkout (Single Payments)
///
/// Exposed internally to test BTPayPalDriver app switch return behavior by simulating an app switch return
- (void)setCheckoutAppSwitchReturnBlock:(void (^)(__BT_NULLABLE BTTokenizedPayPalCheckout *tokenizedCheckout, __BT_NULLABLE NSError *error))completionBlock;

/// Set up the callback to be invoked on return from browser or app switch for PayPal Authorization (Future Payments)
///
/// Exposed internally to test BTPayPalDriver app switch return behavior by simulating an app switch return
- (void)setAuthorizationAppSwitchReturnBlock:(void (^)(__BT_NULLABLE BTTokenizedPayPalAccount *tokenizedAccount, __BT_NULLABLE NSError *error))completionBlock;

/// Exposed for testing to create stubbed versions of `PayPalOneTouchAuthorizationRequest` and
/// `PayPalOneTouchCheckoutRequest`
@property (nonatomic, strong) BTPayPalRequestFactory *requestFactory;

/// Exposed for testing to provide subclasses of PayPalOneTouchCore to stub class methods
@property (nonatomic, strong) Class payPalClass;

/// Exposed for testing to validate analytics
@property (nonatomic, strong) BTAnalyticsClient *analyticsClient;

@end

BT_ASSUME_NONNULL_END
