#import "BTCardClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient ()

/// Exposed for testing to get the instance of BTAPIClient
@property (nonatomic, strong, readwrite) BTAPIClient *apiClient;

@end

NS_ASSUME_NONNULL_END
