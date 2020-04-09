#import "BTPayPalUAT.h"
#import "BTJSON.h"

NSString * const BTPayPalUATErrorDomain = @"com.braintreepayments.BTPayPalUATErrorDomain";

@implementation BTPayPalUAT

- (instancetype)init {
    return nil;
}

- (nullable instancetype)initWithUATString:(NSString *)uatString error:(NSError **)error {
    self = [super init];
    if (self) {
        BTJSON *json = [self decodeUATString:uatString error:error];
        
        if (error && *error) {
            return nil;
        }
        
        NSArray *externalIds = [json[@"external_ids"] asArray];
        NSString *braintreeMerchantID;
        for (NSString *externalId in externalIds) {
            if ([externalId hasPrefix:@"Braintree:"]) {
                braintreeMerchantID = [externalId componentsSeparatedByString:@":"][1];
                break;
            }
        }
        
        if (!braintreeMerchantID) {
            if (error) {
                *error = [NSError errorWithDomain:BTPayPalUATErrorDomain
                                             code:BTPayPalUATErrorUnlinkedAccount
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal UAT: Associated Braintree merchant ID missing."}];
            }
            return nil;
        }

        NSString *basePayPalURL = [json[@"iss"] asString];
        
        NSString *braintreeGatewayURL;
        
        // TODO: - get the braintree URL from the PP UAT instead of hardcoding; waiting for PP UAT to include BT endpoint
        if ([basePayPalURL isEqualToString:@"https://api.paypal.com"] ) {
            braintreeGatewayURL = @"https://api.braintreegateway.com:443";
        } else if ([basePayPalURL isEqualToString:@"https://api.msmaster.qa.paypal.com"]
                   || [basePayPalURL isEqualToString:@"https://api.sandbox.paypal.com"]) {
            braintreeGatewayURL = @"https://api.sandbox.braintreegateway.com:443";
        }

        if (!basePayPalURL || !braintreeGatewayURL) {
            if (error) {
                *error = [NSError errorWithDomain:BTPayPalUATErrorDomain
                                             code:BTPayPalUATErrorInvalid
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal UAT: Issuer missing or unknown."}];
            }
            return nil;
        }
        
        _basePayPalURL = [NSURL URLWithString:basePayPalURL];
        _baseBraintreeURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/merchants/%@/client_api", braintreeGatewayURL, braintreeMerchantID]];
        _configURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/configuration", _baseBraintreeURL]];
        _token = uatString;
    }

    return self;
}

- (BTJSON *)decodeUATString:(NSString *)uatString error:(NSError * __autoreleasing *)error {
    NSArray *payPalUATComponents = [uatString componentsSeparatedByString:@"."];
    
    if (payPalUATComponents.count != 3) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalUATErrorDomain
                                         code:BTPayPalUATErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal UAT: Missing payload."}];
        }
        return nil;
    }
    
    NSString *base64EncodedBody = [self base64EncodedStringWithPadding:payPalUATComponents[1]];

    NSData *base64DecodedPayPalUAT = [[NSData alloc] initWithBase64EncodedString:base64EncodedBody options:0];
    if (!base64DecodedPayPalUAT) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalUATErrorDomain
                                         code:BTPayPalUATErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:@"Invalid PayPal UAT: Unable to base-64 decode payload."}];
        }
        return nil;
    }
    
    NSDictionary *rawPayPalUAT;
    NSError *JSONError = nil;
    rawPayPalUAT = [NSJSONSerialization JSONObjectWithData:base64DecodedPayPalUAT options:0 error:&JSONError];

    if (JSONError) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalUATErrorDomain
                                         code:BTPayPalUATErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid PayPal UAT: %@", JSONError.localizedDescription]}];
        }
        return nil;
    }

    if (![rawPayPalUAT isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [NSError errorWithDomain:BTPayPalUATErrorDomain
                                         code:BTPayPalUATErrorInvalid
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid PayPal UAT: Expected to find an object at JSON root."}];
        }
        return nil;
    }

    return [[BTJSON alloc] initWithValue:rawPayPalUAT];
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
