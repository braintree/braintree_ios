#import "BTAnalyticsService.h"
#import "BTAPIClient.h"
#import "BTClientMetadata.h"
#import "BTClientToken.h"
#import "BTHTTP.h"
#import "BTJSON.h"

@class BTPaymentMethodNonce;

@interface BTAPIClient ()
@property (nonatomic, copy) NSString *tokenizationKey;
@property (nonatomic, strong) BTClientToken *clientToken;
@property (nonatomic, strong) BTHTTP *http;
@property (nonatomic, strong) BTHTTP *configurationHTTP;

/// Client metadata that is used for tracking the client session
@property (nonatomic, readonly, strong) BTClientMetadata *metadata;

/// Exposed for testing analytics
@property (nonatomic, strong) BTAnalyticsService *analyticsService;

/// Analytics should only be posted by internal clients.
- (void)sendAnalyticsEvent:(NSString *)eventName;

/// An internal initializer to toggle whether to send an analytics event during initialization.
/// This prevents copyWithSource:integration: from sending a duplicate event. It can also be used
/// to suppress excessive network chatter during testing.
- (instancetype)initWithAuthorization:(NSString *)authorization sendAnalyticsEvent:(BOOL)sendAnalyticsEvent;

/// Fetches payment methods. Must be using client token.
///
/// @param sortedDefaultFirst Sort payment method nonces with the default payment method first.
/// @param completionBlock Callback that returns an array of payment method nonces
- (void)fetchPaymentMethodNoncesSorted:(BOOL)sortDefaultFirst completion:(void(^)(NSArray <BTPaymentMethodNonce *> *paymentMethodNonces, NSError *error))completionBlock;

@end
