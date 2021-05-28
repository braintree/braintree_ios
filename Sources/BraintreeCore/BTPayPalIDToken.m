#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTPayPalIDToken.h>
#import <Braintree/BTJSON.h>
#else
#import <BraintreeCore/BTPayPalIDToken.h>
#import <BraintreeCore/BTJSON.h>
#endif

NSString * const BTPayPalIDTokenErrorDomain = @"com.braintreepayments.BTPayPalIDTokenErrorDomain";

@implementation BTPayPalIDToken

- (instancetype)init {
    return nil;
}

- (nullable instancetype)initWithIDTokenString:(NSString *)idTokenString error:(NSError **)error {
    self = [super init];
    if (self) {
        BTJSON *json = [self decodeIDTokenString:idTokenString error:error];
        
        if (error && *error) {
            return nil;
        }
        
        NSArray *externalIDs = [json[@"external_id"] asStringArray];
        for (NSString *externalID in externalIDs) {
            if ([externalID hasPrefix:@"Braintree:"]) {
                _braintreeMerchantID = [externalID componentsSeparatedByString:@":"][1];
            } else if ([externalID hasPrefix:@"PayPal:"]) {
                _paypalMerchantID = [externalID componentsSeparatedByString:@":"][1];
            }
        }
        
        if (!_braintreeMerchantID) {
            if (error) {
                *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                             code:BTPayPalIDTokenErrorUnlinkedAccount
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal ID Token: Associated Braintree merchant ID missing."}];
            }
            return nil;
        } else if (!_paypalMerchantID) {
            if (error) {
                *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                             code:BTPayPalIDTokenErrorUnlinkedAccount
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal ID Token: Associated PayPal merchant ID missing."}];
            }
            return nil;
        }

        NSString *basePayPalURL = [json[@"iss"] asString];
        
        NSString *braintreeGatewayURL;
        
        if ([basePayPalURL isEqualToString:@"https://api.paypal.com"] ) {
            _environment = BTPayPalIDTokenEnvironmentProd;
            braintreeGatewayURL = @"https://api.braintreegateway.com:443";
        } else if ([basePayPalURL isEqualToString:@"https://api.sandbox.paypal.com"]) {
            _environment = BTPayPalIDTokenEnvironmentSand;
            braintreeGatewayURL = @"https://api.sandbox.braintreegateway.com:443";
        } else if ([basePayPalURL isEqualToString:@"https://api.msmaster.qa.paypal.com"]) {
            _environment = BTPayPalIDTokenEnvironmentStage;
            braintreeGatewayURL = @"https://api.sandbox.braintreegateway.com:443";
        } else {
            if (error) {
                *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                             code:BTPayPalIDTokenErrorInvalid
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal ID Token: Issuer missing or unknown."}];
            }
            return nil;
        }
        
        _basePayPalURL = [NSURL URLWithString:basePayPalURL];
        _baseBraintreeURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/merchants/%@/client_api", braintreeGatewayURL, _braintreeMerchantID]];
        _configURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/configuration", _baseBraintreeURL]];
        _token = idTokenString;
    }

    return self;
}

- (BTJSON *)decodeIDTokenString:(NSString *)idTokenString error:(NSError * __autoreleasing *)error {
    NSArray *payPalIDTokenComponents = [idTokenString componentsSeparatedByString:@"."];
    
    if (payPalIDTokenComponents.count != 3) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                         code:BTPayPalIDTokenErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal ID Token: Missing payload."}];
        }
        return nil;
    }
    
    NSString *base64EncodedBody = [self base64EncodedStringWithPadding:payPalIDTokenComponents[1]];

    NSData *base64DecodedPayPalIDToken = [[NSData alloc] initWithBase64EncodedString:base64EncodedBody options:0];
    if (!base64DecodedPayPalIDToken) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                         code:BTPayPalIDTokenErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal ID Token: Unable to base-64 decode payload."}];
        }
        return nil;
    }
    
    NSDictionary *rawPayPalIDToken;
    NSError *JSONError = nil;
    rawPayPalIDToken = [NSJSONSerialization JSONObjectWithData:base64DecodedPayPalIDToken options:0 error:&JSONError];

    if (JSONError) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                         code:BTPayPalIDTokenErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid PayPal ID Token: %@", JSONError.localizedDescription]}];
        }
        return nil;
    }

    if (![rawPayPalIDToken isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalIDTokenErrorDomain
                                         code:BTPayPalIDTokenErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid PayPal ID Token: Expected to find an object at JSON root."}];
        }
        return nil;
    }

    return [[BTJSON alloc] initWithValue:rawPayPalIDToken];
}

- (NSString *)base64EncodedStringWithPadding:(NSString *)base64EncodedString {
    if (base64EncodedString.length % 4 == 2) {
        return [NSString stringWithFormat:@"%@==", base64EncodedString];
    } else if (base64EncodedString.length % 4 == 3) {
        return [NSString stringWithFormat:@"%@=", base64EncodedString];
    } else {
        return base64EncodedString;
    }
}

@end
