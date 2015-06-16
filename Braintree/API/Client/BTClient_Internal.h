#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"
#import "BTConfiguration.h"
#import "BTClientMetadata.h"

#import "BTThreeDSecureLookupResult.h"

/// Success Block type for 3D Secure lookups
typedef void (^BTClientThreeDSecureLookupSuccessBlock)(BTThreeDSecureLookupResult *threeDSecureLookup);

/// Block type that takes a `BTClient` or an error
typedef void (^BTClientCompletionBlock)(BTClient *client, NSError *error);

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *configHttp;
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;

/// Models the contents of the client token, as it is received from the merchant server
@property (nonatomic, strong) BTClientToken *clientToken;
@property (nonatomic, strong) BTConfiguration *configuration;
@property (nonatomic) BOOL hasConfiguration; // YES if configuration was retrieved directly from Braintree, rather than from the client token

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

/// Begins the setup of `BTClient` with a client token.
/// The client token dictates the behavior of subsequent operations.
///
/// *Not used at this time.* Use -initWithClientToken: instead.
///
/// @param clientTokenString Braintree client token
/// @param completionBlock callback will be called exactly once asynchronously, providing either an instance of BTClient upon success or an error upon failure.
+ (void)setupWithClientToken:(NSString *)clientTokenString completion:(BTClientCompletionBlock)completionBlock;

@end
