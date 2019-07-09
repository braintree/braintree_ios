#import <Foundation/Foundation.h>
#import "BTThreeDSecureV2Provider.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureAuthenticateJWT : NSObject

+ (void)authenticateJWT:(NSString *)cardinalJWT
          withAPIClient:(BTAPIClient *)apiClient
        forLookupResult:(BTThreeDSecureLookup *)lookupResult
                success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler;

@end

NS_ASSUME_NONNULL_END
