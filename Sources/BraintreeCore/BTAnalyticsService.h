#import <Foundation/Foundation.h>
@class BTAPIClient;
@class BTHTTP;

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for analytics service errors.
 */
extern NSString * const BTAnalyticsServiceErrorDomain;

/**
 Error codes associated with analytics services.
 */
typedef NS_ENUM(NSUInteger, BTAnalyticsServiceErrorType) {
    /// Unknown error
    BTAnalyticsServiceErrorTypeUnknown = 1,
    
    /// Missing analytics url
    BTAnalyticsServiceErrorTypeMissingAnalyticsURL,
    
    /// Invalid API client
    BTAnalyticsServiceErrorTypeInvalidAPIClient,
};

@interface BTAnalyticsService : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

/**
 Defaults to 1, can be overridden
*/
@property (nonatomic, assign) NSUInteger flushThreshold;

@property (nonatomic, strong) BTAPIClient *apiClient;

/**
 Tracks an event.

 Events are queued and sent in batches to the analytics service, based on the status of the app
 and the number of queued events. After exiting this method, there is no guarantee that the event has been
 sent.
*/
- (void)sendAnalyticsEvent:(NSString *)eventKind;

/**
 Tracks an event and sends it to the analytics service. It will also flush any queued events.

 @param completionBlock A callback that is invoked when the analytics service has completed.
*/
- (void)sendAnalyticsEvent:(NSString *)eventKind completion:(nullable void(^)(NSError * _Nullable))completionBlock;

/**
 Sends all queued events to the analytics service.

 @param completionBlock A callback that is invoked when the analytics service has completed.
*/
- (void)flush:(nullable void (^)(NSError * _Nullable error))completionBlock;

/**
 The HTTP client for communication with the analytics service endpoint. Exposed for testing.
*/
@property (nonatomic, strong) BTHTTP *http;

@end

NS_ASSUME_NONNULL_END
