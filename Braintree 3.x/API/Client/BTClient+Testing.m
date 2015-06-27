#import "BTClient_Internal.h"
#import "BTClient+Testing.h"

#import "BTHTTP.h"

NSString *BTClientTestConfigurationKeyMerchantIdentifier = @"merchant_id";
NSString *BTClientTestConfigurationKeyPublicKey = @"publicKey";
NSString *BTClientTestConfigurationKeyCustomer = @"customer";
NSString *BTClientTestConfigurationKeyNoCustomer = @"no_customer";
NSString *BTClientTestConfigurationKeySharedCustomerIdentifier = @"sharedCustomerIdentifier";
NSString *BTClientTestConfigurationKeySharedCustomerIdentifierType = @"sharedCustomerIdentifierType";
NSString *BTClientTestConfigurationKeyPayPalClientId = @"paypalClientId";
NSString *BTClientTestConfigurationKeyRevoked = @"authorizationFingerprintRevoked";
NSString *BTClientTestConfigurationKeyClientTokenVersion = @"tokenVersion";
NSString *BTClientTestConfigurationKeyAnalytics = @"analytics";
NSString *BTClientTestConfigurationKeyURL = @"url";
NSString *BTClientTestConfigurationKeyMerchantAccountIdentifier = @"merchantAccountId";

NSString *BTClientTestDefaultMerchantIdentifier = @"integration_merchant_id";

@implementation BTClient (Testing)

+ (void)testClientWithConfiguration:(NSDictionary *)configurationDictionary async:(BOOL)async completion:(void (^)(BTClient *client))completionBlock {
    NSAssert(completionBlock != nil, @"Completion is required in %s", __FUNCTION__);

    BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:[[self class] testClientApiURLForMerchant:configurationDictionary[BTClientTestConfigurationKeyMerchantIdentifier]]];

    NSMutableDictionary *overrides = [NSMutableDictionary dictionaryWithDictionary:configurationDictionary];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray *topLevelParams = @[ BTClientTestConfigurationKeyMerchantIdentifier,
                                 BTClientTestConfigurationKeyPublicKey,
                                 BTClientTestConfigurationKeyCustomer,
                                 BTClientTestConfigurationKeyNoCustomer,
                                 BTClientTestConfigurationKeyClientTokenVersion,
                                 BTClientTestConfigurationKeyRevoked,
                                 BTClientTestConfigurationKeySharedCustomerIdentifierType,
                                 BTClientTestConfigurationKeySharedCustomerIdentifier,
                                 BTClientTestConfigurationKeyMerchantAccountIdentifier, ];

    for (NSString *topLevelParam in topLevelParams) {
        if (configurationDictionary[topLevelParam]) {
            parameters[topLevelParam] = configurationDictionary[topLevelParam];
        }
        [overrides removeObjectForKey:topLevelParam];
    }
    parameters[@"overrides"] = overrides;

    [http POST:@"testing/client_token"
    parameters:parameters
    completion:^(BTHTTPResponse *response, __unused NSError *error) {
        if (error != nil) {
            NSLog(@"testing/client_token failed or responded with an error: %@", error);
            NSLog(@"\n\n====================================================================\n=      ARE YOU RUNNING THE GATEWAY ON http://localhost:3000?       =\n====================================================================\n\n");
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:nil userInfo:nil];
        }
        
        NSString *clientTokenString = [response.object stringForKey:@"clientToken"];
        if (async) {
          [BTClient setupWithClientToken:clientTokenString completion:^(BTClient *client, NSError *error) {
            NSAssert(client != nil, @"BTClient setup failed with error = %@", error);
            if (client == nil) { NSLog(@"BTClient setup failed with error = %@", error); }
            completionBlock(client);
          }];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
          completionBlock([(BTClient *)[BTClient alloc] initWithClientToken:clientTokenString]);
#pragma clang diagnostic pop
        }

    }];
}

- (void)fetchNonceInfo:(NSString *)nonce success:(BTClientNonceInfoSuccessBlock)successBlock failure:(BTClientFailureBlock)failureBlock {
    NSMutableCharacterSet *nonceParamCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [nonceParamCharacterSet addCharactersInString:@"-"];

    NSString *path = [NSString stringWithFormat:@"nonces/%@", [nonce stringByAddingPercentEncodingWithAllowedCharacters:nonceParamCharacterSet]];

    [self.clientApiHttp GET:path parameters:[self defaultRequestParameters] completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            if (successBlock != nil) {
                successBlock([response.object dictionaryForKey:@"nonce"]);
            }
        } else {
            NSError *returnedError = error;
            if (error.domain == BTBraintreeAPIErrorDomain && error.code == BTMerchantIntegrationErrorNotFound) {
                returnedError = [NSError errorWithDomain:error.domain
                                                    code:BTMerchantIntegrationErrorNonceNotFound
                                                userInfo:@{NSUnderlyingErrorKey: error}];
            }
            if (failureBlock != nil) {
                failureBlock(returnedError);
            }
        }
    }];
}

- (void)fetchNonceThreeDSecureVerificationInfo:(NSString *)nonce
                                       success:(BTClientNonceInfoSuccessBlock)successBlock
                                       failure:(BTClientFailureBlock)failureBlock {
    NSMutableCharacterSet *nonceParamCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [nonceParamCharacterSet addCharactersInString:@"-"];

    NSString *path = [NSString stringWithFormat:@"testing/three_d_secure_verifications/nonce/%@", [nonce stringByAddingPercentEncodingWithAllowedCharacters:nonceParamCharacterSet]];

    NSDictionary *params = @{ @"public_key": @"integration_public_key", };
    [self.clientApiHttp GET:path parameters:params completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            if (successBlock != nil) {
                successBlock([response.object dictionaryForKey:@"threeDSecureVerification"]);
            }
        } else {
            NSError *returnedError = error;
            if (error.domain == BTBraintreeAPIErrorDomain && error.code == BTMerchantIntegrationErrorNotFound) {
                returnedError = [NSError errorWithDomain:error.domain
                                                    code:BTMerchantIntegrationErrorNonceNotFound
                                                userInfo:@{NSUnderlyingErrorKey: error}];
            }
            if (failureBlock != nil) {
                failureBlock(returnedError);
            }
        }
    }];
}

- (void)revokeAuthorizationFingerprintForTestingWithSuccess:(void (^)(void))successBlock
                                               failure:(BTClientFailureBlock)failureBlock {
    [self.clientApiHttp DELETE:@"testing/authorization_fingerprints"
                    parameters:[self defaultRequestParameters]
                    completion:^(BTHTTPResponse *response, NSError *error) {
                        if (response.isSuccess) {
                            if (successBlock) {
                            successBlock();
                            }
                        } else {
                            if (failureBlock) {
                                failureBlock(error);
                            }
                        }
                    }];
}

- (void)updateCoinbaseMerchantOptions:(NSDictionary *)dictionary
                         success:(void (^)(void))successBlock
                              failure:(BTClientFailureBlock)failureBlock {
   [self.clientApiHttp PUT:@"testing/mock_coinbase_merchant_options"
                parameters:@{ @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                              @"coinbase_merchant_options": dictionary }
                completion:^(BTHTTPResponse *response, NSError *error) {
                    if (response.isSuccess) {
                        if (successBlock) {
                            successBlock();
                        }
                    } else {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }
                }];
}

- (NSDictionary *)defaultRequestParameters {
    return @{ @"authorization_fingerprint": self.clientToken.authorizationFingerprint };
}

+ (NSURL *)testClientApiURLForMerchant:(NSString *)merchantIdentifier {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/merchants/%@/client_api/", merchantIdentifier ?: BTClientTestDefaultMerchantIdentifier]];
}

@end
