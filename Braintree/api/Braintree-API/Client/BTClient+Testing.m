#import "BTClientToken.h"
#import "BTClient_Internal.h"
#import "BTClient+Testing.h"


#import "BTHTTP.h"

NSString *BTClientTestConfigurationKeyMerchantIdentifier = @"merchant_id";
NSString *BTClientTestConfigurationKeyPublicKey = @"publicKey";
NSString *BTClientTestConfigurationKeyCustomer = @"customer";
NSString *BTClientTestConfigurationKeySharedCustomerIdentifier = @"sharedCustomerIdentifier";
NSString *BTClientTestConfigurationKeySharedCustomerIdentifierType = @"sharedCustomerIdentifierType";
NSString *BTClientTestConfigurationKeyPayPalClientId = @"paypalClientId";
NSString *BTClientTestConfigurationKeyRevoked = @"authorizationFingerprintRevoked";
NSString *BTClientTestConfigurationKeyClientTokenVersion = @"tokenVersion";
NSString *BTClientTestConfigurationKeyAnalytics = @"analytics";
NSString *BTClientTestConfigurationKeyURL = @"url";

NSString *BTClientTestDefaultMerchantIdentifier = @"integration_merchant_id";

@implementation BTClient (Testing)

+ (void)testClientWithConfiguration:(NSDictionary *)configurationDictionary completion:(void (^)(BTClient *client))block {
    NSAssert(block != nil, @"Completion is required in %s", __FUNCTION__);

    BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:[[self class] testClientApiURLForMerchant:configurationDictionary[BTClientTestConfigurationKeyMerchantIdentifier]]];

    NSMutableDictionary *overrides = [NSMutableDictionary dictionaryWithDictionary:configurationDictionary];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray *topLevelParams = @[ BTClientTestConfigurationKeyMerchantIdentifier,
                                 BTClientTestConfigurationKeyPublicKey,
                                 BTClientTestConfigurationKeyCustomer,
                                 BTClientTestConfigurationKeyClientTokenVersion,
                                 BTClientTestConfigurationKeyRevoked,
                                 BTClientTestConfigurationKeySharedCustomerIdentifierType,
                                 BTClientTestConfigurationKeySharedCustomerIdentifier ];

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
        NSAssert(error == nil, @"testing/client_token failed or responded with an error: %@", error);
        NSString *clientTokenString = response.object[@"clientToken"];

        block([[self alloc] initWithClientToken:clientTokenString]);
    }];
}

- (void)fetchNonceInfo:(NSString *)nonce success:(BTClientNonceInfoSuccessBlock)successBlock failure:(BTClientFailureBlock)failureBlock {
    NSMutableCharacterSet *nonceParamCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [nonceParamCharacterSet addCharactersInString:@"-"];

    NSString *path = [NSString stringWithFormat:@"nonces/%@", [nonce stringByAddingPercentEncodingWithAllowedCharacters:nonceParamCharacterSet]];

    [self.clientApiHttp GET:path parameters:[self defaultRequestParameters] completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            if (successBlock != nil) {
                successBlock(response.object[@"nonce"]);
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

- (NSDictionary *)defaultRequestParameters {
    return @{ @"authorization_fingerprint": self.clientToken.authorizationFingerprint };
}

+ (NSURL *)testClientApiURLForMerchant:(NSString *)merchantIdentifier {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/merchants/%@/client_api/", merchantIdentifier ?: BTClientTestDefaultMerchantIdentifier]];
}

@end
