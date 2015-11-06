#import "BTCardClient.h"

@interface BTCardClient ()

/// Exposed for testing to get the instance of BTAPIClient
@property (nonatomic, strong, readwrite) BTAPIClient *apiClient;

@end
