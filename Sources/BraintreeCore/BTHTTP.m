#import "BTHTTP.h"
#import "Braintree-Version.h"
#import "BTAPIPinnedCertificates.h"
#import "BTLogger_Internal.h"
#import "BTCacheDateValidator_Internal.h"
#include <sys/sysctl.h>

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTClientToken.h>
#import <Braintree/BTHTTPErrors.h>
#import <Braintree/BTJSON.h>
#import <Braintree/BTURLUtils.h>
#else
#import <BraintreeCore/BTClientToken.h>
#import <BraintreeCore/BTHTTPErrors.h>
#import <BraintreeCore/BTJSON.h>
#import <BraintreeCore/BTURLUtils.h>
#endif

@interface BTHTTP () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, copy) NSString *authorizationFingerprint;
@property (nonatomic, copy) NSString *tokenizationKey;

@end

@implementation BTHTTP

- (instancetype)init {
    return nil;
}

- (instancetype)initWithBaseURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        self.baseURL = URL;
        self.cacheDateValidator = [[BTCacheDateValidator alloc] init];
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)URL authorizationFingerprint:(NSString *)authorizationFingerprint {
    self = [self initWithBaseURL:URL];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = self.defaultHeaders;

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.name = @"com.braintreepayments.BTHTTP";
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;

        self.authorizationFingerprint = authorizationFingerprint;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
        self.pinnedCertificates = [BTAPIPinnedCertificates trustedCertificates];
    }
    return self;
}

- (instancetype)initWithBaseURL:(nonnull NSURL *)URL tokenizationKey:(nonnull NSString *)tokenizationKey {
    if (self = [self initWithBaseURL:URL]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = self.defaultHeaders;

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.name = @"com.braintreepayments.BTHTTP";
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;

        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
        self.pinnedCertificates = [BTAPIPinnedCertificates trustedCertificates];
        self.tokenizationKey = tokenizationKey;
    }
    return self;
}

- (instancetype)initWithClientToken:(BTClientToken *)clientToken {
    return [self initWithBaseURL:[clientToken.json[@"clientApiUrl"] asURL] authorizationFingerprint:clientToken.authorizationFingerprint];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BTHTTP *copiedHTTP;
    if (self.authorizationFingerprint) {
        copiedHTTP = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL authorizationFingerprint:self.authorizationFingerprint];
    } else {
        copiedHTTP = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL tokenizationKey:self.tokenizationKey];
    }
    
    copiedHTTP.pinnedCertificates = [_pinnedCertificates copy];
    return copiedHTTP;
}

- (void)setSession:(NSURLSession *)session {
    if (_session) {
        // If we already have a session, we need to invalidate it so that the session delegate is released to prevent a retain cycle
        [_session invalidateAndCancel];
    }

    _session = session;
}

#pragma mark - HTTP Methods

- (void)GET:(NSString *)aPath completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self GET:aPath parameters:nil completion:completionBlock];
}

- (void)GET:(NSString *)aPath parameters:(NSDictionary *)parameters shouldCache:(BOOL)shouldCache completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    if (shouldCache) {
        [self httpRequestWithCaching:@"GET" path:aPath parameters:parameters completion:completionBlock];
    } else {
        [self httpRequest:@"GET" path:aPath parameters:parameters completion:completionBlock];
    }
}

- (void)GET:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self httpRequest:@"GET" path:aPath parameters:parameters completion:completionBlock];
}

- (void)POST:(NSString *)aPath completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self POST:aPath parameters:nil completion:completionBlock];
}

- (void)POST:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self httpRequest:@"POST" path:aPath parameters:parameters completion:completionBlock];
}

- (void)PUT:(NSString *)aPath completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self PUT:aPath parameters:nil completion:completionBlock];
}

- (void)PUT:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self httpRequest:@"PUT" path:aPath parameters:parameters completion:completionBlock];
}

- (void)DELETE:(NSString *)aPath completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self DELETE:aPath parameters:nil completion:completionBlock];
}

- (void)DELETE:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self httpRequest:@"DELETE" path:aPath parameters:parameters completion:completionBlock];
}

#pragma mark - Underlying HTTP

- (void)httpRequestWithCaching:(NSString *)method path:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self createRequest:method path:aPath parameters:parameters completion:^(NSURLRequest *request, NSError *error) {
        if (error != nil) {
            [self handleRequestCompletion:nil request:nil shouldCache:NO response:nil error:error completionBlock:completionBlock];
            return;
        }
        
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        
        if ([self.cacheDateValidator isCacheInvalid:cachedResponse]) {
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            cachedResponse = nil;
        }
        
        // The increase in speed of API calls with cached configuration caused an increase in "network connection lost" errors.
        // Adding this delay allows us to throttle the network requests slightly to reduce load on the servers and decrease connection lost errors.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (cachedResponse != nil) {
                [self handleRequestCompletion:cachedResponse.data request:nil shouldCache:NO response:cachedResponse.response error:nil completionBlock:completionBlock];
            } else {
                NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    [self handleRequestCompletion:data request:request shouldCache:YES response:response error:error completionBlock:completionBlock];
                }];
                [task resume];
            }
        });
    }];
}

- (void)httpRequest:(NSString *)method path:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self createRequest:method path:aPath parameters:parameters completion:^(NSURLRequest *request, NSError *error) {
        if (error != nil) {
            [self handleRequestCompletion:nil request:nil shouldCache:NO response:nil error:error completionBlock:completionBlock];
            return;
        }
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self handleRequestCompletion:data request:request shouldCache:NO response:response error:error completionBlock:completionBlock];
        }];
        [task resume];
    }];
}

- (void)createRequest:(NSString *)method path:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(NSURLRequest *request, NSError *error))completionBlock {
    BOOL hasHttpPrefix = aPath != nil && [aPath hasPrefix:@"http"];
    if (!hasHttpPrefix && (!self.baseURL || [self.baseURL.absoluteString isEqualToString:@""])) {
        NSMutableDictionary *errorUserInfo = [NSMutableDictionary new];
        if (method) errorUserInfo[@"method"] = method;
        if (aPath) errorUserInfo[@"path"] = aPath;
        if (parameters) errorUserInfo[@"parameters"] = parameters;
        completionBlock(nil, [NSError errorWithDomain:BTHTTPErrorDomain code:BTHTTPErrorCodeMissingBaseURL userInfo:errorUserInfo]);
        return;
    }

    BOOL isNotDataURL = ![self.baseURL.scheme isEqualToString:@"data"];
    NSURL *fullPathURL;
    if (aPath && isNotDataURL) {
        if (hasHttpPrefix) {
            fullPathURL = [NSURL URLWithString:aPath];
        } else {
            fullPathURL = [self.baseURL URLByAppendingPathComponent:aPath];
        }
    } else {
        fullPathURL = self.baseURL;
    }

    if (parameters == nil) {
        parameters = [NSDictionary dictionary];
    }
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (self.authorizationFingerprint) {
        mutableParameters[@"authorization_fingerprint"] = self.authorizationFingerprint;
    }
    parameters = [mutableParameters copy];

    if (!fullPathURL) {
        // baseURL can be non-nil (e.g. an empty string) and still return nil for -URLByAppendingPathComponent:
        // causing a crash when NSURLComponents.componentsWithString is called with nil.
        NSMutableDictionary *errorUserInfo = [NSMutableDictionary new];
        if (method) errorUserInfo[@"method"] = method;
        if (aPath) errorUserInfo[@"path"] = aPath;
        if (parameters) errorUserInfo[@"parameters"] = parameters;
        errorUserInfo[NSLocalizedFailureReasonErrorKey] = @"fullPathURL was nil";
        completionBlock(nil, [NSError errorWithDomain:BTHTTPErrorDomain code:BTHTTPErrorCodeMissingBaseURL userInfo:errorUserInfo]);
        return;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithString:fullPathURL.absoluteString];

    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.defaultHeaders];

    NSMutableURLRequest *request;

    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"]) {
        if (isNotDataURL) {
            components.percentEncodedQuery = [BTURLUtils queryStringWithDictionary:parameters];
        }
        request = [NSMutableURLRequest requestWithURL:components.URL];
    } else {
        request = [NSMutableURLRequest requestWithURL:components.URL];

        NSError *jsonSerializationError;
        NSData *bodyData;

        if ([parameters isKindOfClass:[NSDictionary class]]) {
            bodyData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:0
                                                         error:&jsonSerializationError];
        }

        if (jsonSerializationError != nil) {
            completionBlock(nil, jsonSerializationError);
            return;
        }

        [request setHTTPBody:bodyData];
        headers[@"Content-Type"]  = @"application/json; charset=utf-8";
    }
    if (self.tokenizationKey) {
        headers[@"Client-Key"] = self.tokenizationKey;
    }
    [request setAllHTTPHeaderFields:headers];

    [request setHTTPMethod:method];
    
    completionBlock(request, nil);
}

- (void)handleRequestCompletion:(NSData *)data request:(NSURLRequest *)request shouldCache:(BOOL)shouldCache response:(NSURLResponse *)response error:(NSError *)error completionBlock:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    // Handle errors for which the response is irrelevant
    // e.g. SSL, unavailable network, etc.
    if (error != nil) {
        [self callCompletionBlock:completionBlock body:nil response:nil error:error];
        return;
    }

    NSHTTPURLResponse *httpResponse;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)response;
    } else if ([response.URL.scheme isEqualToString:@"data"]) {
        httpResponse = [[NSHTTPURLResponse alloc] initWithURL:response.URL statusCode:200 HTTPVersion:nil headerFields:nil];
    }

    NSString *responseContentType = [response MIMEType];

    NSMutableDictionary *errorUserInfo = [NSMutableDictionary new];
    errorUserInfo[BTHTTPURLResponseKey] = httpResponse;

    if (httpResponse.statusCode >= 400) {
        errorUserInfo[NSLocalizedFailureReasonErrorKey] = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];

        BTJSON *json;
        if ([responseContentType isEqualToString:@"application/json"]) {
            json = (data.length == 0) ? [BTJSON new] : [[BTJSON alloc] initWithData:data];
            if (!json.isError) {
                errorUserInfo[BTHTTPJSONResponseBodyKey] = json;
                NSString *errorResponseMessage = [json[@"error"][@"developer_message"] isString] ? [json[@"error"][@"developer_message"] asString] : [json[@"error"][@"message"] asString];
                if (errorResponseMessage) {
                    errorUserInfo[NSLocalizedDescriptionKey] = errorResponseMessage;
                }
            }
        }
        
        BTHTTPErrorCode errorCode = httpResponse.statusCode >= 500 ? BTHTTPErrorCodeServerError : BTHTTPErrorCodeClientError;
        if (httpResponse.statusCode == 429) {
            errorCode = BTHTTPErrorCodeRateLimitError;
            errorUserInfo[NSLocalizedDescriptionKey] = @"You are being rate-limited.";
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = @"Please try again in a few minutes.";
        } else if (httpResponse.statusCode >= 500) {
            errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = @"Please try again later.";
        }
        
        NSError *error = [NSError errorWithDomain:BTHTTPErrorDomain
                                                     code:errorCode
                                                 userInfo:[errorUserInfo copy]];
        [self callCompletionBlock:completionBlock body:json response:httpResponse error:error];
        return;
    }

    // Empty response is valid
    BTJSON *json = (data.length == 0) ? [BTJSON new] : [[BTJSON alloc] initWithData:data];
    if (json.isError) {
        if (![responseContentType isEqualToString:@"application/json"]) {
            // Return error for unsupported response type
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = [NSString stringWithFormat:@"BTHTTP only supports application/json responses, received Content-Type: %@", responseContentType];
            NSError *returnedError = [NSError errorWithDomain:BTHTTPErrorDomain
                                                         code:BTHTTPErrorCodeResponseContentTypeNotAcceptable
                                                     userInfo:[errorUserInfo copy]];
            [self callCompletionBlock:completionBlock body:nil response:nil error:returnedError];
        } else {
            [self callCompletionBlock:completionBlock body:nil response:nil error:json.asError];
        }
        return;
    }
    
    // We should only cache the response if we do not have an error and status code is 2xx
    BOOL successStatusCode = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300;
    if (request != nil && shouldCache && successStatusCode) {
        NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc]initWithResponse:response data:data];
        [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:request];
    }

    [self callCompletionBlock:completionBlock body:json response:httpResponse error:nil];
}

- (void)callCompletionBlock:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock
                       body:(BTJSON *)jsonBody
                   response:(NSHTTPURLResponse *)response
                      error:(NSError *)error {
    if (completionBlock) {
        dispatch_async(self.dispatchQueue, ^{
            completionBlock(jsonBody, response, error);
        });
    }
}

- (dispatch_queue_t)dispatchQueue {
    return _dispatchQueue ?: dispatch_get_main_queue();
}

#pragma mark - Default Headers

- (NSDictionary *)defaultHeaders {
    return @{ @"User-Agent": [self userAgentString],
              @"Accept": [self acceptString],
              @"Accept-Language": [self acceptLanguageString] };
}

- (NSString *)userAgentString {
    return [NSString stringWithFormat:@"Braintree/iOS/%@", BRAINTREE_VERSION];
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

- (NSArray *)pinnedCertificateData {
    NSMutableArray *pinnedCertificates = [NSMutableArray array];
    for (NSData *certificateData in self.pinnedCertificates) {
        [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
    }
    return pinnedCertificates;
}

- (void)URLSession:(__unused NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSString *domain = challenge.protectionSpace.host;
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];

        NSArray *policies = @[(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
        SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)self.pinnedCertificateData);

        CFErrorRef error;
        BOOL trusted = SecTrustEvaluateWithError(serverTrust, &error);

        if (trusted && error == nil) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, NULL);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
    }
}

- (BOOL)isEqualToHTTP:(BTHTTP *)http {
    return [self.baseURL isEqual:http.baseURL] && [self.authorizationFingerprint isEqualToString:http.authorizationFingerprint];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if ([object isKindOfClass:[BTHTTP class]]) {
        return [self isEqualToHTTP:object];
    }

    return NO;
}

@end
