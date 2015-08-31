#import "BTOfflineModeURLProtocol.h"
#import "BTOfflineClientBackend.h"
#import "BTMutableApplePayPaymentMethod.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"
#import <objc/runtime.h>

NSString *const BTOfflineModeClientApiBaseURL = @"braintree-api-offline-http://client-api";
NSString *const BTOfflineModeHTTPVersionString = @"HTTP/1.1";

void *backend_associated_object_key = &backend_associated_object_key;

static BTOfflineClientBackend *backend;

@implementation BTOfflineModeURLProtocol

+ (NSURL *)clientApiBaseURL {
    return [NSURL URLWithString:BTOfflineModeClientApiBaseURL];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL *requestURL = request.URL;

    BOOL hasCorrectScheme = [requestURL.scheme isEqualToString:[[self clientApiBaseURL] scheme]];
    BOOL hasCorrectHost = [requestURL.host isEqualToString:[[self clientApiBaseURL] host]];

    return hasCorrectScheme && hasCorrectHost;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = self.client;
    NSURLRequest *request = self.request;

    __block NSHTTPURLResponse *response;
    __block NSData *responseData;

    if ([request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/v1/payment_methods"]) {
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                               statusCode:200
                                              HTTPVersion:BTOfflineModeHTTPVersionString
                                             headerFields:@{@"Content-Type": @"application/json" }];

        NSMutableArray *responseCards = [NSMutableArray array];
        for (BTPaymentMethod *paymentMethod in [[[self class] backend] allPaymentMethods]) {
            [responseCards addObject:[self responseDictionaryForPaymentMethod:paymentMethod]];
        }

        responseData = ({
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"paymentMethods": responseCards}
                                                           options:0
                                                             error:&error];
            NSAssert(error == nil, @"Error writing offline mode JSON response: %@", error);
            data;
        });
    } else if ([request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/v1/payment_methods/credit_cards"]) {

        NSDictionary *requestObject = [self queryDictionaryFromRequest:request];

        NSString *number = requestObject[@"credit_card"][@"number"];
        NSString *lastTwo = [number substringFromIndex:([number length] - 2)];

        BTMutableCardPaymentMethod *card = [BTMutableCardPaymentMethod new];
        card.lastTwo = lastTwo;
        card.typeString = [self cardTypeStringForNumber:number];

        if (card) {
            [[[self class] backend] addPaymentMethod:card];

            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:201
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{@"Content-Type": @"application/json"}];
            responseData = ({
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"creditCards": @[ [self responseDictionaryForPaymentMethod:card] ] }
                                                               options:0
                                                                 error:&error];
                NSAssert(error == nil, @"Error writing offline mode JSON response: %@", error);
                data;
            });
        } else {
            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:501
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{}];
            responseData = nil;
        }
    } else if ([request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/v1/payment_methods/apple_payment_tokens"]) {
        NSDictionary *requestObject = [self queryDictionaryFromRequest:request];
        NSDictionary *payment = requestObject[@"applePaymentToken"];
        if (payment) {
#if BT_ENABLE_APPLE_PAY
            BTMutableApplePayPaymentMethod *apple = [[BTMutableApplePayPaymentMethod alloc] init];
            [[[self class] backend] addPaymentMethod:apple];

            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:201
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{@"Content-Type": @"application/json"}];
            responseData = ({
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"applePayCards": @[ [self responseDictionaryForApplePayPayment] ] }
                                                               options:0
                                                                 error:&error];
                NSAssert(error == nil, @"Error writing offline mode JSON response: %@", error);
                data;
            });
#else
            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:501
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{}];
            responseData = nil;
#endif
        } else {
            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:501
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{}];
            responseData = nil;
        }

    } else if ([request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/v1/payment_methods/paypal_accounts"]) {
        BTMutablePayPalPaymentMethod *payPalPaymentMethod = [BTMutablePayPalPaymentMethod new];
        payPalPaymentMethod.email = @"fake.paypal.customer@example.com";

        if (payPalPaymentMethod) {
            [[[self class] backend] addPaymentMethod:payPalPaymentMethod];
            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:201
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{@"Content-Type": @"application/json"}];

            responseData = ({
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"paypalAccounts": @[ [self responseDictionaryForPaymentMethod:payPalPaymentMethod] ] }
                                                               options:0
                                                                 error:&error];
                NSAssert(error == nil, @"Error writing offline mode JSON response: %@", error);
                data;
            });
        } else {
            response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                   statusCode:501
                                                  HTTPVersion:BTOfflineModeHTTPVersionString
                                                 headerFields:@{}];
            responseData = nil;
        }
    } else if ([request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/v1/analytics"]) {
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                               statusCode:201
                                              HTTPVersion:BTOfflineModeHTTPVersionString
                                             headerFields:@{ @"Content-Type": @"application/json" }];

        responseData = ({
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"message": @"created", @"amount": @2 }
                                                           options:0
                                                             error:&error];
            NSAssert(error == nil, @"Error writing offline mode JSON response: %@", error);
            data;
        });
    } else if ([request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/configuration"]) {
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                               statusCode:200
                                              HTTPVersion:BTOfflineModeHTTPVersionString
                                             headerFields:@{@"Content-Type": @"application/json" }];
        Class TestConfigurationFactoryClass = [NSClassFromString(@"BTTestClientTokenFactory") class];
        NSDictionary *testConfiguration = TestConfigurationFactoryClass ? (NSDictionary *)[TestConfigurationFactoryClass performSelector:@selector(configuration)] :
        @{
          @"applePay": @{ @"status": @"mock",
                          @"countryCode": @"US",
                          @"currencyCode": @"USD",
                          @"supportedNetworks": @[ @"visa", @"mastercard", @"amex" ],
                          @"merchantIdentifier": @"offline-mode-apple-merchant-identifier" }
          };
        responseData = ({
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:testConfiguration
                                                           options:0
                                                             error:&error];
            NSAssert(error == nil, @"Error writing offline mode JSON response: %@", error);
            data;
        });
    } else {
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                               statusCode:501
                                              HTTPVersion:BTOfflineModeHTTPVersionString
                                             headerFields:@{}];
        responseData = nil;
    }

    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    if (responseData) {
        [client URLProtocol:self didLoadData:responseData];
    }

    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

#pragma mark Request Parsing

- (NSDictionary *)queryDictionaryFromRequest:(NSURLRequest *)request {

    NSData *bodyData;
    if (request.HTTPBodyStream) {
        NSInputStream *inputStream = request.HTTPBodyStream;
        [inputStream open];
        NSMutableData *mutableBodyData = [NSMutableData data];

        while ([inputStream hasBytesAvailable]) {
            uint8_t buffer[128];
            NSUInteger bytesRead = [inputStream read:buffer maxLength:128];
            [mutableBodyData appendBytes:buffer length:bytesRead];
        }
        [inputStream close];
        bodyData = [mutableBodyData copy];
    } else {
        bodyData = request.HTTPBody;
    }
    NSString *contentType = request.allHTTPHeaderFields[@"Content-Type"];
    if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
        return result;
    } else {
        NSString *queryString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
        for (NSString *parameter in parameters) {
            NSArray *parts = [parameter componentsSeparatedByString:@"="];
            NSString *key = [[parts objectAtIndex:0] stringByRemovingPercentEncoding];
            if ([parts count] > 1) {
                id value = [[parts objectAtIndex:1] stringByRemovingPercentEncoding];
                [result setObject:value forKey:key];
            }
        }
        return result;
    }
}

#pragma mark Response Generation

- (NSDictionary *)responseDictionaryForPaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([paymentMethod isKindOfClass:[BTCardPaymentMethod class]]) {
        return [self responseDictionaryForCard:(BTCardPaymentMethod *)paymentMethod];
    } else if ([paymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
        return [self responseDictionaryForPayPalPaymentMethod];
    } else {
        return nil;
    }
}

- (NSDictionary *)responseDictionaryForApplePayPayment {
    return @{
             @"nonce": [self generateNonce],
             @"type": @"ApplePayCard"
             };
}

- (NSDictionary *)responseDictionaryForCard:(BTCardPaymentMethod *)card {
    return @{
             @"nonce": [self generateNonce],
             @"details": @{
                     @"lastTwo": card.lastTwo,
                     @"cardType": card.typeString,
                     },
             @"isLocked": @0,
             @"securityQuestions": @[@"cvv"],
             @"type": @"CreditCard"
             };
}

- (NSDictionary *)responseDictionaryForPayPalPaymentMethod {
    return @{
             @"description": @"PayPal",
             @"nonce": [self generateNonce],
             @"isLocked": @0,
             @"details": @{ @"email": @"email@example.com" },
             @"type": @"PayPalAccount"
             };
}

- (NSString *)generateNonce {
    static unsigned int initialNonceValue = 0;
    initialNonceValue++;
    return [NSString stringWithFormat:@"00000000-0000-0000-0000-%012x", initialNonceValue];
}

#pragma mark Offline Card Data

+ (NSDictionary *)cardNamesAndRegexes {
    NSMutableDictionary *cardNamesAndRegex = [NSMutableDictionary dictionary];

    NSDictionary *cardNamesAndRegexPatterns = @{
                                                @"Visa": @"^4[0-9]",
                                                @"MasterCard": @"^5[1-5]",
                                                @"American Express": @"^3[47]",
                                                @"Diners Club": @"^3(?:0[0-5]|[68][0-9])",
                                                @"Discover": @"^6(?:011|5[0-9]{2})",
                                                @"JCB": @"^(?:2131|1800|35)" };

    for (NSString *cardType in [cardNamesAndRegexPatterns allKeys]) {
        NSError *error;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:cardNamesAndRegexPatterns[cardType] options:0 error:&error];
        NSAssert(error == nil, @"Could not compile card type detection regex for offline client: %@", error);
        cardNamesAndRegex[cardType] = regex;
    }

    return cardNamesAndRegex;
}

- (NSString *)cardTypeStringForNumber:(NSString *)number {
    NSDictionary *cardNamesAndRegex = [[self class] cardNamesAndRegexes];

    for (NSString *cardType in [cardNamesAndRegex allKeys]) {
        NSRegularExpression *regex = cardNamesAndRegex[cardType];
        if ([regex numberOfMatchesInString:number options:0 range:NSMakeRange(0, [number length])] > 0) {
            return cardType;
        }
    }

    return nil;
}

#pragma mark - Offline Client Backend

+ (BTOfflineClientBackend *)backend {
    return objc_getAssociatedObject(self, backend_associated_object_key);
}

+ (void)setBackend:(BTOfflineClientBackend *)backend {
    objc_setAssociatedObject(self, backend_associated_object_key, backend, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
