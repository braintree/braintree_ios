#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTAPIClient.h>
#else
#import <BraintreeCore/BTAPIClient.h>
#endif

@class BTAnalyticsService;
@class BTAPIHTTP;
@class BTClientMetadata;
@class BTClientToken;
@class BTGraphQLHTTP;
@class BTHTTP;
@class BTJSON;
@class BTPaymentMethodNonce;
@class BTPayPalIDToken;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BTAPIClientAuthorizationType) {
    BTAPIClientAuthorizationTypeTokenizationKey = 0,
    BTAPIClientAuthorizationTypeClientToken,
    BTAPIClientAuthorizationTypePayPalIDToken,
};

@interface BTAPIClient ()

@property (nonatomic, copy, nullable) NSString *tokenizationKey;
@property (nonatomic, strong, nullable) BTClientToken *clientToken;
@property (nonatomic, strong, nullable) BTPayPalIDToken *payPalIDToken;
@property (nonatomic, strong) BTHTTP *http;
@property (nonatomic, strong) BTHTTP *configurationHTTP;
@property (nonatomic, strong) BTAPIHTTP *braintreeAPI;
@property (nonatomic, strong) BTGraphQLHTTP *graphQL;

/**
 Client metadata that is used for tracking the client session
*/
@property (nonatomic, readonly, strong) BTClientMetadata *metadata;

/**
 Exposed for testing analytics
*/
@property (nonatomic, strong) BTAnalyticsService *analyticsService;

/**
 Sends this event and all queued analytics events. Use `queueAnalyticsEvent` for low priority events.
*/
- (void)sendAnalyticsEvent:(NSString *)eventName;

/**
 Queues an analytics event to be sent.
 */
- (void)queueAnalyticsEvent:(NSString *)eventName;

/**
 An internal initializer to toggle whether to send an analytics event during initialization.
 This prevents copyWithSource:integration: from sending a duplicate event. It can also be used to suppress excessive network chatter during testing.
*/
- (nullable instancetype)initWithAuthorization:(NSString *)authorization sendAnalyticsEvent:(BOOL)sendAnalyticsEvent;

/**
 Gets base GraphQL URL
*/
+ (nullable NSURL *)graphQLURLForEnvironment:(NSString *)environment;

/**
 Determines the BTAPIClientAuthorizationType of the given authorization string.  Exposed for testing.
 */
+ (BTAPIClientAuthorizationType)authorizationTypeForAuthorization:(NSString *)authorization;

@end

NS_ASSUME_NONNULL_END
