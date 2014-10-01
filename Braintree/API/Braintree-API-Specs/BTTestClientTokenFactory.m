#import "BTTestClientTokenFactory.h"

@implementation BTTestClientTokenFactory

+ (NSMutableDictionary *)tokenDataWithConfiguration {
    return [@{
              @"authorizationFingerprint": @"an_authorization_fingerprint",
              @"configUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration",
              @"challenges": @[
                      @"cvv"
                      ],
              @"paymentApps": @[],
              @"clientApiUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api",
              @"assetsUrl": @"https://assets.example.com",
              @"authUrl": @"https://auth.venmo.example.com",
              @"analytics": @{
                      @"url": @"https://client-analytics.example.com"
                      },
              @"threeDSecureEnabled": @NO,
              @"paypalEnabled": @YES,
              @"paypal": @{
                      @"displayName": @"Acme Widgets, Ltd. (Sandbox)",
                      @"clientId": @"a_paypal_client_id",
                      @"privacyUrl": @"http://example.com/pp",
                      @"userAgreementUrl": @"http://example.com/tos",
                      @"baseUrl": @"https://assets.example.com",
                      @"assetsUrl": @"https://checkout.paypal.example.com",
                      @"directBaseUrl": [NSNull null],
                      @"allowHttp": @YES,
                      @"environmentNoNetwork": @YES,
                      @"environment": @"offline",
                      @"merchantAccountId": @"a_merchant_account_id",
                      @"currencyIsoCode": @"USD"
                      },
              @"merchantId": @"a_merchant_id",
              @"venmo": @"offline",
              @"applePay": @{ @"status": @"mock" }
              } mutableCopy];
}

+ (NSMutableDictionary *)configuration {
    return [@{
              @"version": @3,
              @"challenges": @[
                      @"cvv"
                      ],
              @"paymentApps": @[],
              @"clientApiUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api",
              @"assetsUrl": @"https://assets.example.com",
              @"authUrl": @"https://auth.venmo.example.com",
              @"analytics": @{
                      @"url": @"https://client-analytics.example.com"
                      },
              @"threeDSecureEnabled": @NO,
              @"paypalEnabled": @YES,
              @"paypal": @{
                      @"displayName": @"Acme Widgets, Ltd. (Sandbox)",
                      @"clientId": @"a_paypal_client_id",
                      @"privacyUrl": @"http://example.com/pp",
                      @"userAgreementUrl": @"http://example.com/tos",
                      @"baseUrl": @"https://assets.example.com",
                      @"assetsUrl": @"https://checkout.paypal.example.com",
                      @"directBaseUrl": [NSNull null],
                      @"allowHttp": @YES,
                      @"environmentNoNetwork": @YES,
                      @"environment": @"offline",
                      @"merchantAccountId": @"a_merchant_account_id",
                      @"currencyIsoCode": @"USD"
                      },
              @"merchantId": @"a_merchant_id",
              @"venmo": @"offline",
              @"applePay": @{ @"status": @"mock" }
              } mutableCopy];
}

+ (NSMutableDictionary *)tokenDataWithoutConfiguration {
    return [@{
              @"authorizationFingerprint": @"an_authorization_fingerprint",
              @"configUrl": @"https://example.com:443/merchants/a_merchant_id/client_api/v1/configuration"
              } mutableCopy];
}

+ (NSString *)tokenWithVersion:(NSInteger)version {
    return [self tokenWithVersion:version overrides:nil];
}
+ (NSString *)tokenWithVersion:(NSInteger)version
                     overrides:(NSDictionary *)overrides {
    BOOL base64Encoded;
    NSMutableDictionary *baseTokenData;

    switch (version) {
        case 3:
            base64Encoded = YES;
            baseTokenData = [self tokenDataWithoutConfiguration];
            break;
        case 2:
            base64Encoded = YES;
            baseTokenData = [self tokenDataWithConfiguration];
            break;
        case 1:
            base64Encoded = NO;
            baseTokenData = [self tokenDataWithConfiguration];
            break;
        default:
            return nil;
            break;
    }

    baseTokenData[@"version"] = @(version);

    [overrides enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop){
        if([obj isKindOfClass:[NSNull class]]) {
            [baseTokenData removeObjectForKey:key];
        } else {
            [baseTokenData setObject:obj forKey:key];
        }
    }];

    NSError *jsonSerializationError;
    NSData *configurationData = [NSJSONSerialization dataWithJSONObject:baseTokenData
                                                                options:0
                                                                  error:&jsonSerializationError];
    NSAssert(jsonSerializationError == nil, @"Failed to generated test client token JSON: %@", jsonSerializationError);

    if (base64Encoded) {
        return [configurationData base64EncodedStringWithOptions:0];
    } else {
        return [[NSString alloc] initWithData:configurationData
                                     encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)token {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"paymentAppSchemes\": [\"bt-test-venmo\",\"bt-test-paypal\"]}";
}

+ (NSString *)tokenWithMerchantId:(NSString *)merchantId {
    return [NSString stringWithFormat:@"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"merchantId\":\"%@\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}", merchantId];
}

+ (NSString *)tokenWithAnalyticsUrl:(NSString *)analyticsUrl {
    return [[[NSString stringWithFormat:@"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\", \"analytics\": {\"url\": \"%@\" }}", analyticsUrl] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

}

+ (NSString *)base64EncodedToken {
    return [[[self token] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSString *)base64EncodedTokenWithMerchantId:(NSString *)merchantId {
    return [[[self tokenWithMerchantId:merchantId] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSString *)base64EncodedTokenFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString *)tokenWithPayPalClientId {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"paypalClientId\":\"testPayPalClientId\"}";
}

+ (NSString *)invalidToken {
    return [self tokenWithoutAuthorizationFingerprint];
}

+ (NSString *)tokenWithoutCustomerIdentifier {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithoutAuthorizationUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithoutClientApiUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\"}";
}

+ (NSString *)tokenWithoutAuthorizationFingerprint {
    return @"{\"not_authorization_fingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithBlankAuthorizationUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithBlankClientApiUrl {
    return @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key\",\"clientApiUrl\":\"\"}";
}

+ (NSString *)tokenWithBlankAuthorizationFingerprint {
    return @"{\"authorizationFingerprint\":\"\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}";
}

+ (NSString *)tokenWithTestURLs {
    return [NSString stringWithFormat:@"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"%@://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\"}", [self testURLScheme]];
}

+ (NSString *)testURLScheme {
    return @"bt-test-client-token-scheme";
}

@end