#import "BTHTTP.h"

#include <sys/sysctl.h>

#import "BTClient.h"
#import "BTAPIPinnedCertificates.h"

@interface BTHTTP ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;

- (NSDictionary *)defaultHeaders;

@end

@implementation BTHTTP

- (instancetype)initWithBaseURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = self.defaultHeaders;
        self.baseURL = URL;

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;

        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
        self.pinnedCertificates = [BTAPIPinnedCertificates trustedCertificates];
    }
    return self;
}

#pragma mark - Getters/setters

- (void)setProtocolClasses:(NSArray *)protocolClasses {
    NSURLSessionConfiguration *configuration = self.session.configuration;
    configuration.protocolClasses = protocolClasses;
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.session.delegateQueue];
}

#pragma mark - HTTP Methods

- (void)GET:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self GET:aPath parameters:nil completion:completionBlock];
}

- (void)GET:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self httpRequest:@"GET" path:aPath parameters:parameters completion:completionBlock];
}

- (void)POST:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self POST:aPath parameters:nil completion:completionBlock];
}

- (void)POST:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self httpRequest:@"POST" path:aPath parameters:parameters completion:completionBlock];
}

- (void)PUT:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self PUT:aPath parameters:nil completion:completionBlock];
}

- (void)PUT:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self httpRequest:@"PUT" path:aPath parameters:parameters completion:completionBlock];
}

- (void)DELETE:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self DELETE:aPath parameters:nil completion:completionBlock];
}

- (void)DELETE:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self httpRequest:@"DELETE" path:aPath parameters:parameters completion:completionBlock];
}

#pragma mark - Underlying HTTP

- (void)httpRequest:(NSString *)method path:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {

    NSURL *fullPathURL = [self.baseURL URLByAppendingPathComponent:aPath];
    NSURLComponents *components = [NSURLComponents componentsWithString:fullPathURL.absoluteString];

    NSMutableURLRequest *request;

    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"]) {
        NSString *encodedParametersString = [[self class] queryStringWithDictionary:parameters];
        components.percentEncodedQuery = encodedParametersString;
        request = [NSMutableURLRequest requestWithURL:components.URL];
    } else {
        request = [NSMutableURLRequest requestWithURL:components.URL];

        NSError *jsonSerializationError;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&jsonSerializationError];
        if (jsonSerializationError != nil) {
            completionBlock(nil, [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                     code:BTServerErrorUnknown
                                                 userInfo:@{NSUnderlyingErrorKey: jsonSerializationError}]);
            return;
        } else {
            [request setHTTPBody:bodyData];
        }
        NSDictionary *headers = @{@"Content-Type": @"application/json; charset=utf-8"};
        [request setAllHTTPHeaderFields:headers];
    }
    [request setHTTPMethod:method];

    // Perform the actual request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[self class] handleRequestCompletion:data response:response error:error completionBlock:completionBlock];
    }];
    [task resume];
}

+ (void)handleRequestCompletion:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error completionBlock:(BTHTTPCompletionBlock)completionBlock {

    // Handle errors for which the response is irrelevant
    // e.g. SSL, unavailable network, etc.
    NSError *domainRequestError = [self domainRequestErrorForError:error];
    if (domainRequestError != nil) {
        [self callCompletionBlock:completionBlock response:nil error:domainRequestError];
        return;
    }

    // Handle nil or non-HTTP requests, which are an unknown type of error
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *userInfoDictionary = error ? @{NSUnderlyingErrorKey: error} : nil;
        NSError *returnedError = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                     code:BTServerErrorUnknown
                                                 userInfo:userInfoDictionary];
        [self callCompletionBlock:completionBlock response:nil error:returnedError];
        return;
    }

    // Attempt to parse, and return an error if parsing fails
    NSError *jsonParseError;
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
    if (jsonParseError != nil) {
        NSError *returnedError = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                     code:BTServerErrorUnknown
                                                 userInfo:@{NSUnderlyingErrorKey: jsonParseError}];
        [self callCompletionBlock:completionBlock response:nil error:returnedError];
        return;
    }

    // Determine domain error
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    BTHTTPResponse *btHTTPResponse = [[BTHTTPResponse alloc] initWithStatusCode:httpResponse.statusCode responseObject:responseObject];
    NSError *returnedError = [self defaultDomainErrorForStatusCode:httpResponse.statusCode error:error];
    [self callCompletionBlock:completionBlock response:btHTTPResponse error:returnedError];
}

+ (void)callCompletionBlock:(BTHTTPCompletionBlock)completionBlock response:(BTHTTPResponse *)response error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(response, error);
    });
}

#pragma mark - Error Classification

+ (NSError *)domainRequestErrorForError:(NSError *)error {
    NSError *returnedError;
    if (error != nil) {
        NSDictionary *userInfoDictionary = @{NSUnderlyingErrorKey: error};
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            NSInteger returnedErrorCode;
            switch (error.code) {
                case NSURLErrorSecureConnectionFailed:
                case NSURLErrorServerCertificateHasBadDate:
                case NSURLErrorServerCertificateUntrusted:
                case NSURLErrorServerCertificateHasUnknownRoot:
                case NSURLErrorServerCertificateNotYetValid:
                case NSURLErrorClientCertificateRejected:
                case NSURLErrorClientCertificateRequired:
                case NSURLErrorCannotLoadFromNetwork:
                    returnedErrorCode = BTServerErrorSSL;
                    break;
                default:
                    returnedErrorCode = BTServerErrorNetworkUnavailable;
                    break;
            }
            returnedError = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                code:returnedErrorCode
                                            userInfo:userInfoDictionary];
        } else if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSPropertyListReadCorruptError) {
            returnedError = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                code:BTServerErrorUnexpectedError
                                            userInfo:userInfoDictionary];
        }
    }
    return returnedError;
}

+ (NSError *)defaultDomainErrorForStatusCode:(NSInteger)statusCode error:(NSError *)error {
    NSDictionary *userInfoDictionary = error ? @{NSUnderlyingErrorKey: error} : nil;
    switch (statusCode) {
        case 200 ... 299:
            return nil;
        case 403:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTMerchantIntegrationErrorUnauthorized
                                   userInfo:userInfoDictionary];
        case 404:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTMerchantIntegrationErrorNotFound
                                   userInfo:userInfoDictionary];
        case 422:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTCustomerInputErrorInvalid
                                   userInfo:userInfoDictionary];
        case 400 ... 402:
        case 405 ... 421:
        case 423 ... 499:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTCustomerInputErrorUnknown
                                   userInfo:userInfoDictionary];
        case 503:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTServerErrorGatewayUnavailable
                                   userInfo:userInfoDictionary];
        case 500 ... 502:
        case 504 ... 599:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTServerErrorUnknown
                                   userInfo:userInfoDictionary];
        default:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTUnknownError
                                   userInfo:userInfoDictionary];
    }
}

#pragma mark - Default Headers

- (NSDictionary *)defaultHeaders {
    return @{ @"User-Agent": [self userAgentString],
              @"Accept": [self acceptString],
              @"Accept-Language": [self acceptLanguageString] };
}

- (NSString *)userAgentString {
    // braintree-api-ios/1.0.0 iOS/4.3.2 iPhone2,1
    NSString *userInterfaceIdiom;
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPhone:
            userInterfaceIdiom = @"iPhone";
            break;
        case UIUserInterfaceIdiomPad:
            userInterfaceIdiom = @"iPad";
            break;
        default:
            userInterfaceIdiom = @"unknown";
    }

    return [NSString stringWithFormat:@"braintree-api-ios/%@ %@/%@ %@/%@",
            [BTClient libraryVersion],
            userInterfaceIdiom,
            [[UIDevice currentDevice] systemVersion],
            [self platformString],
            [self architectureString]];
}

- (NSString *)platformString {
    size_t size = 128;
    char *hwModel = alloca(size);

    if (sysctlbyname("hw.model", hwModel, &size, NULL, 0) != 0) {
        return nil;
    }

    NSString *hwModelString = [NSString stringWithCString:hwModel encoding:NSUTF8StringEncoding];
#if TARGET_IPHONE_SIMULATOR
    hwModelString = [hwModelString stringByAppendingString:@"(simulator)"];
#endif
    return hwModelString;
}

- (NSString *)architectureString {
    size_t size = 128;
    char *hwMachine = alloca(size);

    if (sysctlbyname("hw.machine", hwMachine, &size, NULL, 0) != 0) {
        return nil;
    }

    return [NSString stringWithCString:hwMachine encoding:NSUTF8StringEncoding];
}

- (NSString *)acceptString {
    return @"application/json";
}

- (NSString *)acceptLanguageString {
    NSLocale *locale = [NSLocale currentLocale];
    return [NSString stringWithFormat:@"%@-%@",
            [locale objectForKey:NSLocaleLanguageCode],
            [locale objectForKey:NSLocaleCountryCode]];
}

#pragma mark - Helpers

+ (NSString *)stringByURLEncodingAllCharactersInString:(NSString *)aString {
    NSString *encodedString = (__bridge_transfer NSString * ) CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                      (__bridge CFStringRef)aString,
                                                                                                      NULL,
                                                                                                      (CFStringRef)@"&()<>@,;:\\\"/[]?=+$|^~`{}",
                                                                                                      kCFStringEncodingUTF8);
    return encodedString;
}

+ (NSString *)queryStringWithDictionary:(NSDictionary *)dict {
    NSMutableString *queryString = [NSMutableString string];
    for(id key in dict) {
        NSString *encodedKey = [self stringByURLEncodingAllCharactersInString:[key description]];
        id value = [dict objectForKey:key];
        if([value isKindOfClass:[NSArray class]]) {
            for(id obj in value) {
                [queryString appendFormat:@"%@=%@&",
                 encodedKey,
                 [self stringByURLEncodingAllCharactersInString:[obj description]]
                 ];
            }
        } else if([value isKindOfClass:[NSDictionary class]]) {
            for(id subkey in value) {
                [queryString appendFormat:@"%@%%5B%@%%5D=%@&",
                 encodedKey,
                 [self stringByURLEncodingAllCharactersInString:[subkey description]],
                 [self stringByURLEncodingAllCharactersInString:[[value objectForKey:subkey] description]]
                 ];
            }
        } else if([value isKindOfClass:[NSNull class]]) {
            [queryString appendFormat:@"%@=&", encodedKey];
        } else {
            [queryString appendFormat:@"%@=%@&",
             encodedKey,
             [self stringByURLEncodingAllCharactersInString:[value description]]
             ];
        }
    }
    if([queryString length] > 0) {
        [queryString deleteCharactersInRange:NSMakeRange([queryString length] - 1, 1)]; // remove trailing &
    }
    return queryString;
}

+ (BOOL)serverTrustIsValid:(SecTrustRef)serverTrust {
    BOOL isValid = NO;
    SecTrustResultType result;

    OSStatus errorCode = SecTrustEvaluate(serverTrust, &result);
    isValid = errorCode != 0 && (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    return isValid;
 }

 - (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
     NSArray *policies = @[(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];

     SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);

     CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
     if (certificateCount == 0) {
         return NO;
     }

     NSData *serverRootCertificate = (__bridge_transfer NSData *)SecCertificateCopyData(SecTrustGetCertificateAtIndex(serverTrust, certificateCount-1));

     NSMutableArray *pinnedCertificates = [NSMutableArray array];
     for (NSData *certificateData in self.pinnedCertificates) {
         [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
     }
     SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);

     if (![[self class] serverTrustIsValid:serverTrust]) {
         return NO;
     }

     return [self.pinnedCertificates containsObject:serverRootCertificate];
 }


- (void)URLSession:(__unused NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
	if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust]) {

        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];

        BOOL ok = [self evaluateServerTrust:serverTrust forDomain:challenge.protectionSpace.host];
        if (ok) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        }
	}
    
}


@end
