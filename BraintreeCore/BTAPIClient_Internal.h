#import "BTAnalyticsService.h"
#import "BTAPIClient.h"
#import "BTClientMetadata.h"
#import "BTClientToken.h"
#import "BTHTTP.h"
#import "BTAPIHTTP.h"
#import "BTGraphQLHTTP.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@class BTPaymentMethodNonce;

typedef NS_ENUM(NSInteger, BTAPIClientHTTPType) {
    /// Use the Gateway
    BTAPIClientHTTPTypeGateway = 0,
    
    /// Use the Braintree API
    BTAPIClientHTTPTypeBraintreeAPI,

    /// Use the GraphQL API
    BTAPIClientHTTPTypeGraphQLAPI,
};


@interface BTAPIClient ()

@property (nonatomic, copy, nullable) NSString *tokenizationKey;
@property (nonatomic, strong, nullable) BTClientToken *clientToken;
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

- (void)GET:(NSString *)path
 parameters:(nullable NSDictionary <NSString *, NSString *> *)parameters
 httpType:(BTAPIClientHTTPType)httpType
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)POST:(NSString *)path
  parameters:(nullable NSDictionary *)parameters
  httpType:(BTAPIClientHTTPType)httpType
  completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

/**
 Gets base GraphQL URL
*/
+ (nullable NSURL *)graphQLURLForEnvironment:(NSString *)environment;

@end

NS_ASSUME_NONNULL_END
