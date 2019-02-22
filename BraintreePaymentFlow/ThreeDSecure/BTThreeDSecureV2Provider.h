#import <Foundation/Foundation.h>
#import "BTThreeDSecureResult.h"
#import "BTThreeDSecureLookup.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureV2Provider : NSObject

typedef void (^BTThreeDSecureV2ProviderInitializeCompletionHandler)(NSDictionary *lookupParameters);
typedef void (^BTThreeDSecureV2ProviderSuccessHandler)(BTThreeDSecureResult *result);
typedef void (^BTThreeDSecureV2ProviderFailureHandler)(NSError *error);

+ (instancetype)initializeProviderWithConfiguration:(BTConfiguration *)configuration
                                         completion:(BTThreeDSecureV2ProviderInitializeCompletionHandler)completionHandler;

- (void)processLookupResult:(BTThreeDSecureLookup *)lookupResult
              withAPIClient:(BTAPIClient *)apiClient
                    success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                    failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler;

- (void)authenticateCardinalJWT:(NSString *)cardinalJWT
                forLookupResult:(BTThreeDSecureLookup *)lookupResult
                  withAPIClient:(BTAPIClient *)apiClient
                        success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                        failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler;

@end

NS_ASSUME_NONNULL_END
