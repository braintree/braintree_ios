#import <Foundation/Foundation.h>
@class BTThreeDSecureResult;
@class BTThreeDSecureRequest;
@class BTConfiguration;
@class BTAPIClient;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureV2Provider : NSObject

typedef void (^BTThreeDSecureV2ProviderInitializeCompletionHandler)(NSDictionary *lookupParameters);
typedef void (^BTThreeDSecureV2ProviderSuccessHandler)(BTThreeDSecureResult *result);
typedef void (^BTThreeDSecureV2ProviderFailureHandler)(NSError *error);

+ (instancetype)initializeProviderWithConfiguration:(BTConfiguration *)configuration
                                          apiClient:(BTAPIClient *)apiClient
                                            request:(BTThreeDSecureRequest *)request
                                         completion:(BTThreeDSecureV2ProviderInitializeCompletionHandler)completionHandler;

- (void)processLookupResult:(BTThreeDSecureResult *)lookupResult
                    success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                    failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler;

@end

NS_ASSUME_NONNULL_END
