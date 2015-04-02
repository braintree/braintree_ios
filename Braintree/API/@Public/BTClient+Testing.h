#import "BTClient.h"

/// BTClient test configuration keys
/// To be used in testing and customizing Braintree configuration
extern NSString *BTClientTestConfigurationKeyMerchantIdentifier;
extern NSString *BTClientTestConfigurationKeyPublicKey;
extern NSString *BTClientTestConfigurationKeyCustomer;
extern NSString *BTClientTestConfigurationKeyNoCustomer;
extern NSString *BTClientTestConfigurationKeySharedCustomerIdentifier;
extern NSString *BTClientTestConfigurationKeySharedCustomerIdentifierType;
extern NSString *BTClientTestConfigurationKeyRevoked;
extern NSString *BTClientTestConfigurationKeyClientTokenVersion;
extern NSString *BTClientTestConfigurationKeyAnalytics;
extern NSString *BTClientTestConfigurationKeyURL;
extern NSString *BTClientTestConfigurationKeyMerchantAccountIdentifier;

/// Block type that takes an `NSDictionary` that will contain `nonce` info.
typedef void (^BTClientNonceInfoSuccessBlock)(NSDictionary *nonceInfo);

/// Extensions on `BTClient` for utilizing the testing endpoints in the Gateway
/// in order to perform integration tests without a dedicated merchant server.
///
/// @warnings These methods will not work outside of Braintree.
@interface BTClient (Testing)

/// Obtain a client for integration testing with the attributes specified by the configuration dictionary.
///
/// This method actually makes a request against the gateway in order our integration test suite to create
/// a client without a merchant server that generates real client tokens.
+ (void)testClientWithConfiguration:(NSDictionary *)configurationDictionary async:(BOOL)async completion:(void (^)(BTClient * client))block;

/// Invokes Success block with Nonce Info if a Nonce is found.
- (void)fetchNonceInfo:(NSString *)nonce success:(BTClientNonceInfoSuccessBlock)successBlock failure:(BTClientFailureBlock)failureBlock;

/// Invokes Success block with Nonce Info if a Nonce is found.
- (void)fetchNonceThreeDSecureVerificationInfo:(NSString *)nonce success:(BTClientNonceInfoSuccessBlock)successBlock failure:(BTClientFailureBlock)failureBlock;

/// Ask the gateway to revoke the current authorization fingerprint
///
/// Available internally at Braintree for testing only
- (void)revokeAuthorizationFingerprintForTestingWithSuccess:(void (^)(void))successBlock
                                                    failure:(BTClientFailureBlock)failureBlock;

/// Update coinbase merchant options for testing
///
/// Available internally at Braintree for testing only
- (void)updateCoinbaseMerchantOptions:(NSDictionary *)dictionary
                         success:(void (^)(void))successBlock
                         failure:(BTClientFailureBlock)failureBlock;

@end
