#import <Foundation/Foundation.h>
#import "BTThreeDSecureV2Provider.h"
@class BTAPIClient;
@class BTThreeDSecureResult;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureAuthenticateJWT : NSObject

+ (void)authenticateJWT:(NSString *)cardinalJWT
          withAPIClient:(BTAPIClient *)apiClient
        forLookupResult:(BTThreeDSecureResult *)lookupResult
                success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler;

@end

NS_ASSUME_NONNULL_END
