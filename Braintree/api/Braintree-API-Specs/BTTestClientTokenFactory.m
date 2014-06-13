#import "BTTestClientTokenFactory.h"

@implementation BTTestClientTokenFactory

+ (NSString *)token {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"authUrl\":\"https://auth.example.com:1234\"}";
}

+ (NSString *)base64EncodedToken {
    return [[[self token] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSString *)tokenWithPayPalClientId {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"authUrl\":\"https://auth.example.com:1234\",\"paypalClientId\":\"testPayPalClientId\"}";
}

+ (NSString *)invalidToken {
    return [self tokenWithoutAuthorizationFingerprint];
}

+ (NSString *)tokenWithoutCustomerIdentifier {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"authUrl\":\"https://auth.example.com:1234\"}";
}

+ (NSString *)tokenWithoutAuthorizationUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithoutClientApiUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"authUrl\":\"https://auth.example.com:1234\"}";
}

+ (NSString *)tokenWithoutAuthorizationFingerprint {
    return @"{\"not_authorization_fingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"authUrl\":\"https://auth.example.com:1234\"}";
}

+ (NSString *)tokenWithBlankAuthorizationUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"authUrl\":\"\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithBlankClientApiUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"authUrl\":\"https://auth.example.com:1234\",\"clientApiUrl\":\"\"}";
}

+ (NSString *)tokenWithBlankAuthorizationFingerprint {
    return @"{\"authorizationFingerprint\":\"\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"authUrl\":\"https://auth.example.com:1234\"}";
}

+ (NSString *)tokenWithTestURLs {
    return [NSString stringWithFormat:@"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"%@://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"authUrl\":\"%@://auth.example.com:1234\"}", [self testURLScheme], [self testURLScheme]];
}

+ (NSString *)testURLScheme {
    return @"bt-test-client-token-scheme";
}

@end