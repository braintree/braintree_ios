#import "BTCardClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient ()

/// Exposed for testing to get the instance of BTAPIClient
@property (nonatomic, strong, readwrite) BTAPIClient *apiClient;

/// Exposed for UnionPay to supply additional parameters when tokenizing a card
- (void)tokenizeCard:(BTCard *)card options:(nullable NSDictionary *)options completion:(void (^)(BTCardNonce * _Nullable, NSError * _Nullable))completionBlock;

@end

NS_ASSUME_NONNULL_END
