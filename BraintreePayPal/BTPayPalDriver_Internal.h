#import "BTPayPalDriver.h"
#import "BTPayPalRequestFactory.h"
#import <SafariServices/SafariServices.h>

BT_ASSUME_NONNULL_BEGIN

@interface BTPayPalDriver ()

/// Set up the callback to be invoked on return from browser or app switch for PayPal Checkout (Single Payments)
///
/// Exposed internally to test BTPayPalDriver app switch return behavior by simulating an app switch return
- (void)setCheckoutAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalCheckout * __BT_NULLABLE tokenizedCheckout, NSError * __BT_NULLABLE error))completionBlock;

/// Set up the callback to be invoked on return from browser or app switch for PayPal Authorization (Future Payments)
///
/// Exposed internally to test BTPayPalDriver app switch return behavior by simulating an app switch return
- (void)setAuthorizationAppSwitchReturnBlock:(void (^)(BTTokenizedPayPalAccount * __BT_NULLABLE tokenizedAccount, NSError * __BT_NULLABLE error))completionBlock;

- (void)informDelegatePresentingViewControllerRequestPresent:(NSURL*) appSwitchURL;

- (void)informDelegatePresentingViewControllerNeedsDismissal;

/// Exposed for testing to create stubbed versions of `PayPalOneTouchAuthorizationRequest` and
/// `PayPalOneTouchCheckoutRequest`
@property (nonatomic, strong) BTPayPalRequestFactory *requestFactory;

/// Exposed for testing to provide subclasses of PayPalOneTouchCore to stub class methods
+ (Class)payPalClass;
+ (void)setPayPalClass:(Class)payPalClass;

/// Exposed for testing to provide a convenient way to inject custom return URL schemes
@property (nonatomic, copy) NSString *returnURLScheme;

/// Exposed for testing to get the instance of BTAPIClient after it has been copied by `copyWithSource:integration:`
@property (nonatomic, strong) BTAPIClient *apiClient;

/// Exposed for testing, the clientMetadataId associated with this request
@property (nonatomic, strong) NSString *clientMetadataId;

/// Exposed for testing, the safariViewController instance used for the paypal flow on iOS >=9
@property (nonatomic, strong, nullable) SFSafariViewController *safariViewController;

@end

BT_ASSUME_NONNULL_END
