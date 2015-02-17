#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"
#import "BTClientMetadata.h"

#import "BTThreeDSecureLookupResult.h"

/// Success Block type for 3D Secure lookups
typedef void (^BTClientThreeDSecureLookupSuccessBlock)(BTThreeDSecureLookupResult *threeDSecureLookup);

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;

/// Models the contents of the client token, as it is received from the merchant server
@property (nonatomic, strong) BTClientToken *clientToken;

- (void)lookupNonceForThreeDSecure:(NSString *)nonce
                 transactionAmount:(NSDecimalNumber *)amount
                           success:(BTClientThreeDSecureLookupSuccessBlock)successBlock
                           failure:(BTClientFailureBlock)failureBlock;

@property (nonatomic, copy, readonly) BTClientMetadata *metadata;

///  Copy of the instance, but with different metadata
///
///  Useful for temporary metadata overrides.
///
///  @param metadataBlock block for customizing metadata
- (instancetype)copyWithMetadata:(void (^)(BTClientMutableMetadata *metadata))metadataBlock;

@end
