#import "BTAPIClient_Internal.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTAnalyticsServiceErrorDomain;

typedef NS_ENUM(NSUInteger, BTAnalyticsServiceErrorType) {
    BTAnalyticsServiceErrorTypeUnknown = 1,
    BTAnalyticsServiceErrorTypeMissingAnalyticsURL,
};

@interface BTAnalyticsService : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (void)sendAnalyticsEvent:(NSString *)eventKind;

- (void)sendAnalyticsEvent:(NSString *)eventKind completion:(nullable void(^)(NSError * _Nullable error))completionBlock;

@property (nonatomic, strong) BTHTTP *http;

@end

NS_ASSUME_NONNULL_END
