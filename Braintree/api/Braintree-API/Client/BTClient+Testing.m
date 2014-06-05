#import "BTClientToken.h"

#import "BTClient_Internal.h"
#import "BTClient+Testing.h"


#import "BTHTTP.h"

NSString *BTClientTestConfigurationKeyMerchantIdentifier = @"merchantId";
NSString *BTClientTestConfigurationKeyPublicKey = @"publicKey";
NSString *BTClientTestConfigurationKeyCustomer = @"customer";
NSString *BTClientTestConfigurationKeySharedCustomerIdentifier = @"sharedCustomerIdentifier";
NSString *BTClientTestConfigurationKeySharedCustomerIdentifierType = @"sharedCustomerIdentifierType";
NSString *BTClientTestConfigurationKeyBaseUrl = @"baseUrl";
NSString *BTClientTestConfigurationKeyPayPalClientId = @"paypalClientId";
NSString *BTClientTestConfigurationKeyRevoked = @"authorizationFingerprintRevoked";
NSString *BTClientTestConfigurationKeyClientTokenVersion = @"tokenVersion";

NSString *BTClientTestDefaultMerchantIdentifier = @"integration_merchant_id";

@implementation BTClient (Testing)

+ (void)testClientWithConfiguration:(NSDictionary *)configurationDictionary completion:(void (^)(BTClient *client))block {
    NSAssert(block != nil, @"Completion is required in %s", __FUNCTION__);

    BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:[[self class] testClientApiURLForMerchant:configurationDictionary[BTClientTestConfigurationKeyMerchantIdentifier]]];

    [http POST:@"testing/client_token" parameters:configurationDictionary completion:^(BTHTTPResponse *response, __unused NSError *error) {
        NSAssert(error == nil, @"testing/client_token failed or responded with an error: %@", error);
        NSString *clientTokenString = response.object[@"clientToken"];

        block([[self alloc] initWithClientToken:clientTokenString]);
    }];
}

- (void)fetchNonceInfo:(NSString *)nonce success:(BTClientNonceInfoSuccessBlock)successBlock failure:(BTClientFailureBlock)failureBlock {
    NSMutableCharacterSet *nonceParamCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [nonceParamCharacterSet addCharactersInString:@"-"];

    NSString *path = [NSString stringWithFormat:@"nonces/%@", [nonce stringByAddingPercentEncodingWithAllowedCharacters:nonceParamCharacterSet]];

    [self.http GET:path parameters:[self defaultRequestParameters] completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            successBlock(response.object[@"nonce"]);
        } else {
            NSError *returnedError;
            if (response.statusCode == 404) {
                returnedError = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                    code:BTMerchantIntegrationErrorNonceNotFound
                                                userInfo:@{NSUnderlyingErrorKey: error.userInfo[NSUnderlyingErrorKey]}];
            }
            failureBlock(returnedError);
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
