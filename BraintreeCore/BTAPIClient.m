#import "BTAnalyticsMetadata.h"
#import "BTAnalyticsService.h"
#import "BTAPIClient_Internal.h"
#import "BTClientToken.h"
#import "BTLogger_Internal.h"
#import "BTPaymentMethodNonce.h"
#import "BTPaymentMethodNonceParser.h"

NSString *const BTAPIClientErrorDomain = @"com.braintreepayments.BTAPIClientErrorDomain";

@interface BTAPIClient ()

@property (nonatomic, strong) dispatch_queue_t configurationQueue;

@end

@implementation BTAPIClient

- (nullable instancetype)initWithAuthorization:(NSString *)authorization {
    return [self initWithAuthorization:authorization sendAnalyticsEvent:YES];
}

- (nullable instancetype)initWithAuthorization:(NSString *)authorization sendAnalyticsEvent:(BOOL)sendAnalyticsEvent {
    if(![authorization isKindOfClass:[NSString class]]) {
        NSString *reason = @"BTClient could not initialize because the provided authorization was invalid";
        [[BTLogger sharedLogger] error:reason];
        return nil;
    }

    if (self = [super init]) {
        BTAPIClientAuthorizationType authorizationType = [[self class] authorizationTypeForAuthorization:authorization];
        switch (authorizationType) {
            case BTAPIClientAuthorizationTypeTokenizationKey: {
                NSURL *baseURL = [BTAPIClient baseURLFromTokenizationKey:authorization];

                if (!baseURL) {
                    NSString *reason = @"BTClient could not initialize because the provided tokenization key was invalid";
                    [[BTLogger sharedLogger] error:reason];
                    return nil;
                }

                _tokenizationKey = authorization;
                _configurationHTTP = [[BTHTTP alloc] initWithBaseURL:baseURL tokenizationKey:authorization];

                if (sendAnalyticsEvent) {
                    [self queueAnalyticsEvent:@"ios.started.client-key"];
                }
                break;
            }

            case BTAPIClientAuthorizationTypeClientToken: {
                NSError *error;
                _clientToken = [[BTClientToken alloc] initWithClientToken:authorization error:&error];
                if (error) { [[BTLogger sharedLogger] error:[error localizedDescription]]; }
                if (!_clientToken) {
                    [[BTLogger sharedLogger] error:@"BTClient could not initialize because the provided clientToken was invalid"];
                    return nil;
                }

                _configurationHTTP = [[BTHTTP alloc] initWithClientToken:self.clientToken];

                if (sendAnalyticsEvent) {
                    [self queueAnalyticsEvent:@"ios.started.client-token"];
                }
                break;
            }

            case BTAPIClientAuthorizationTypePayPalIDToken: {
                NSError *error;
                _payPalIDToken = [[BTPayPalIDToken alloc] initWithIDTokenString:authorization error:&error];
                if (!_payPalIDToken || error) {
                    [[BTLogger sharedLogger] error:@"BTClient could not initialize because the provided PayPal ID Token was invalid"];
                    [[BTLogger sharedLogger] error:[error localizedDescription]];
                    return nil;
                }
                
                _configurationHTTP = [[BTHTTP alloc] initWithPayPalIDToken:_payPalIDToken];

                if (sendAnalyticsEvent) {
                    [self queueAnalyticsEvent:@"ios.started.paypal-id-token"];
                }
                break;
            }
        }

        _metadata = [[BTClientMetadata alloc] init];
        _configurationQueue = dispatch_queue_create("com.braintreepayments.BTAPIClient", DISPATCH_QUEUE_SERIAL);

        // BTHTTP's default NSURLSession does not cache responses, but we want the BTHTTP instance that fetches configuration to cache aggressively
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        static NSURLCache *configurationCache;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            configurationCache = [[NSURLCache alloc] initWithMemoryCapacity:1 * 1024 * 1024 diskCapacity:0 diskPath:nil];
        });
        configuration.URLCache = configurationCache;
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        _configurationHTTP.session = [NSURLSession sessionWithConfiguration:configuration];

        // Kickoff the background request to fetch the config
        [self fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration * _Nullable configuration, __unused NSError * _Nullable error) {
            //noop
        }];
    }

    return self;
}

+ (BTAPIClientAuthorizationType)authorizationTypeForAuthorization:(NSString *)authorization {
    NSRegularExpression *isTokenizationKeyRegExp = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[a-zA-Z0-9_]+$" options:0 error:NULL];
    NSTextCheckingResult *tokenizationKeyMatch = [isTokenizationKeyRegExp firstMatchInString:authorization options:0 range: NSMakeRange(0, authorization.length)];

    NSRegularExpression *isPayPalIDTokenRegExp = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]+\\.[a-zA-Z0-9]+\\.[a-zA-Z0-9_-]+$" options:0 error:NULL];
    NSTextCheckingResult *payPalIDTokenMatch = [isPayPalIDTokenRegExp firstMatchInString:authorization options:0 range: NSMakeRange(0, authorization.length)];

    if (tokenizationKeyMatch) {
        return BTAPIClientAuthorizationTypeTokenizationKey;
    } else if (payPalIDTokenMatch) {
        return BTAPIClientAuthorizationTypePayPalIDToken;
    } else {
        return BTAPIClientAuthorizationTypeClientToken;
    }
}

- (instancetype)copyWithSource:(BTClientMetadataSourceType)source
                   integration:(BTClientMetadataIntegrationType)integration
{
    BTAPIClient *copiedClient;

    if (self.clientToken) {
        copiedClient = [[[self class] alloc] initWithAuthorization:self.clientToken.originalValue sendAnalyticsEvent:NO];
    } else if (self.tokenizationKey) {
        copiedClient = [[[self class] alloc] initWithAuthorization:self.tokenizationKey sendAnalyticsEvent:NO];
    } else if (self.payPalIDToken) {
        copiedClient = [[[self class] alloc] initWithAuthorization:self.payPalIDToken.token sendAnalyticsEvent:NO];
    } else {
        NSAssert(NO, @"Cannot copy an API client that does not specify a client token or tokenization key");
    }

    if (copiedClient) {
        BTMutableClientMetadata *mutableMetadata = [self.metadata mutableCopy];
        mutableMetadata.source = source;
        mutableMetadata.integration = integration;
        copiedClient->_metadata = [mutableMetadata copy];
    }

    return copiedClient;
}

#pragma mark - Base URL

///  Gets base URL from tokenization key
///
///  @param tokenizationKey The tokenization key
///
///  @return Base URL for environment, or `nil` if tokenization key is invalid
+ (NSURL *)baseURLFromTokenizationKey:(NSString *)tokenizationKey {
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z0-9]+)_[a-zA-Z0-9]+_([a-zA-Z0-9_]+)" options:0 error:NULL];

    NSArray *results = [regExp matchesInString:tokenizationKey options:0 range:NSMakeRange(0, tokenizationKey.length)];

    if (results.count != 1 || [[results firstObject] numberOfRanges] != 3) {
        return nil;
    }

    NSString *environment = [tokenizationKey substringWithRange:[results[0] rangeAtIndex:1]];
    NSString *merchantID = [tokenizationKey substringWithRange:[results[0] rangeAtIndex:2]];

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [BTAPIClient schemeForEnvironmentString:environment];
    NSString *host = [BTAPIClient hostForEnvironmentString:environment];
    NSArray <NSString *> *hostComponents = [host componentsSeparatedByString:@":"];
    components.host = hostComponents[0];
    if (hostComponents.count > 1) {
        NSString *portString = hostComponents[1];
        components.port = @(portString.integerValue);
    }
    components.path = [BTAPIClient clientApiBasePathForMerchantID:merchantID];
    if (!components.host || !components.path) {
        return nil;
    }

    return components.URL;
}

+ (NSString *)schemeForEnvironmentString:(NSString *)environment {
    if ([[environment lowercaseString] isEqualToString:@"development"]) {
        return @"http";
    }
    return @"https";
}

+ (NSString *)hostForEnvironmentString:(NSString *)environment {
    if ([[environment lowercaseString] isEqualToString:@"sandbox"]) {
        return @"api.sandbox.braintreegateway.com";
    } else if ([[environment lowercaseString] isEqualToString:@"production"]) {
        return @"api.braintreegateway.com:443";
    } else if ([[environment lowercaseString] isEqualToString:@"development"]) {
        return @"localhost:3000";
    } else {
        return nil;
    }
}

+ (NSURL *)graphQLURLForEnvironment:(NSString *)environment {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [BTAPIClient schemeForEnvironmentString:environment];
    NSString *host = [BTAPIClient graphQLHostForEnvironmentString:environment];
    NSArray <NSString *> *hostComponents = [host componentsSeparatedByString:@":"];
    if (hostComponents.count == 0) {
        return nil;
    }
    components.host = hostComponents[0];
    if (hostComponents.count > 1) {
        NSString *portString = hostComponents[1];
        components.port = @(portString.integerValue);
    }
    components.path = @"/graphql";

    return components.URL;
}

+ (NSString *)graphQLHostForEnvironmentString:(NSString *)environment {
    if ([[environment lowercaseString] isEqualToString:@"sandbox"]) {
        return @"payments.sandbox.braintree-api.com";
    } else if ([[environment lowercaseString] isEqualToString:@"development"]) {
        return @"localhost:8080";
    } else {
        return @"payments.braintree-api.com";
    }
}

+ (NSString *)clientApiBasePathForMerchantID:(NSString *)merchantID {
    if (merchantID.length == 0) {
        return nil;
    }

    return [NSString stringWithFormat:@"/merchants/%@/client_api", merchantID];
}

# pragma mark - Payment Methods

- (void)fetchPaymentMethodNonces:(void (^)(NSArray <BTPaymentMethodNonce *> *, NSError *))completion {
    [self fetchPaymentMethodNonces:NO completion:completion];
}

- (void)fetchPaymentMethodNonces:(BOOL)defaultFirst completion:(void (^)(NSArray <BTPaymentMethodNonce *> *, NSError *))completion {
    if (!self.clientToken) {
        NSError *error = [NSError errorWithDomain:BTAPIClientErrorDomain code:BTAPIClientErrorTypeNotAuthorized userInfo:@{ NSLocalizedDescriptionKey : @"Cannot fetch payment method nonces with a tokenization key", NSLocalizedRecoverySuggestionErrorKey : @"This endpoint requires a client token for authorization"}];
        if (completion) {
            completion(nil, error);
        }
        return;
    }

    NSString *defaultFirstValue = defaultFirst ? @"true" : @"false";

    [self GET:@"v1/payment_methods"
             parameters:@{@"default_first": defaultFirstValue,
                          @"session_id": self.metadata.sessionId}
             completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (completion) {
                         if (error) {
                             completion(nil, error);
                         } else {
                             NSMutableArray *paymentMethodNonces = [NSMutableArray array];
                             for (NSDictionary *paymentInfo in [body[@"paymentMethods"] asArray]) {
                                 BTJSON *paymentInfoJSON = [[BTJSON alloc] initWithValue:paymentInfo];
                                 BTPaymentMethodNonce *paymentMethodNonce = [[BTPaymentMethodNonceParser sharedParser] parseJSON:paymentInfoJSON withParsingBlockForType:[paymentInfoJSON[@"type"] asString]];
                                 if (paymentMethodNonce) {
                                     [paymentMethodNonces addObject:paymentMethodNonce];
                                 }
                             }
                             completion(paymentMethodNonces, nil);
                         }
                     }
                 });
    }];
}

#pragma mark - Remote Configuration

- (void)fetchOrReturnRemoteConfiguration:(void (^)(BTConfiguration *, NSError *))completionBlock {
    // Guarantee that multiple calls to this method will successfully obtain configuration exactly once.
    //
    // Rules:
    //   - If cachedConfiguration is present, return it without a request
    //   - If cachedConfiguration is not present, fetch it and cache the succesful response
    //     - If fetching fails, return error and the next queued will try to fetch again
    //
    // Note: Configuration queue is SERIAL. This helps ensure that each request for configuration
    //       is processed independently. Thus, the check for cached configuration and the fetch is an
    //       atomic operation with respect to other calls to this method.
    //
    // Note: Uses dispatch_semaphore to block the configuration queue when the configuration fetch
    //       request is waiting to return. In this context, it is OK to block, as the configuration
    //       queue is a background queue to guarantee atomic access to the remote configuration resource.
    dispatch_async(self.configurationQueue, ^{
        __block NSError *fetchError;

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block BTConfiguration *configuration;
        NSString *configPath = @"v1/configuration"; // Default for tokenizationKey
        if (self.clientToken) {
            configPath = [self.clientToken.configURL absoluteString];
        } else if (self.payPalIDToken) {
            configPath = [self.payPalIDToken.configURL absoluteString];
        }
        [self.configurationHTTP GET:configPath parameters:@{ @"configVersion": @"3" } completion:^(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                fetchError = error;
            } else if (response.statusCode != 200) {
                NSError *configurationDomainError =
                [NSError errorWithDomain:BTAPIClientErrorDomain
                                    code:BTAPIClientErrorTypeConfigurationUnavailable
                                userInfo:@{
                                           NSLocalizedFailureReasonErrorKey: @"Unable to fetch remote configuration from Braintree API at this time."
                                           }];
                fetchError = configurationDomainError;
            } else {
                configuration = [[BTConfiguration alloc] initWithJSON:body];
                if (!self.braintreeAPI) {
                    NSURL *apiURL = [configuration.json[@"braintreeApi"][@"url"] asURL];
                    NSString *accessToken = [configuration.json[@"braintreeApi"][@"accessToken"] asString];
                    self.braintreeAPI = [[BTAPIHTTP alloc] initWithBaseURL:apiURL accessToken:accessToken];
                }
                if (!self.http) {
                    NSURL *baseURL = [configuration.json[@"clientApiUrl"] asURL];
                    if (self.clientToken) {
                        self.http = [[BTHTTP alloc] initWithBaseURL:baseURL authorizationFingerprint:self.clientToken.authorizationFingerprint];
                    } else if (self.tokenizationKey) {
                        self.http = [[BTHTTP alloc] initWithBaseURL:baseURL tokenizationKey:self.tokenizationKey];
                    } else if (self.payPalIDToken) {
                        self.http = [[BTHTTP alloc] initWithBaseURL:baseURL authorizationFingerprint:self.payPalIDToken.token];
                    }
                }
                if (!self.graphQL) {
                    NSURL *graphQLBaseURL = [BTAPIClient graphQLURLForEnvironment:[configuration.json[@"environment"] asString]];
                    if (self.clientToken) {
                        self.graphQL = [[BTGraphQLHTTP alloc] initWithBaseURL:graphQLBaseURL authorizationFingerprint:self.clientToken.authorizationFingerprint];
                    } else if (self.tokenizationKey) {
                        self.graphQL = [[BTGraphQLHTTP alloc] initWithBaseURL:graphQLBaseURL tokenizationKey:self.tokenizationKey];
                    } else if (self.payPalIDToken) {
                        self.graphQL = [[BTGraphQLHTTP alloc] initWithBaseURL:graphQLBaseURL authorizationFingerprint:self.payPalIDToken.token];
                    }
                }
            }

            // Important: Unlock semaphore in all cases
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(configuration, fetchError);
        });
    });
}

#pragma mark - Analytics

/// By default, the `BTAnalyticsService` instance is static/shared so that only one queue of events exists.
/// The "singleton" is managed here because the analytics service depends on `BTAPIClient`.
- (BTAnalyticsService *)analyticsService {
    static BTAnalyticsService *analyticsService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:self];
        analyticsService.flushThreshold = 5;
    });

    // The analytics service may be overridden by unit tests. In that case, return the ivar and not the singleton
    if (_analyticsService) return _analyticsService;

    return analyticsService;
}

- (void)sendAnalyticsEvent:(NSString *)eventKind {
    [self.analyticsService sendAnalyticsEvent:eventKind completion:nil];
}

- (void)queueAnalyticsEvent:(NSString *)eventKind {
    [self.analyticsService sendAnalyticsEvent:eventKind];
}

- (NSDictionary *)metaParameters {
    NSMutableDictionary *metaParameters = [NSMutableDictionary dictionaryWithDictionary:self.metadata.parameters];
    [metaParameters addEntriesFromDictionary:[BTAnalyticsMetadata metadata]];

    return [metaParameters copy];
}

- (NSDictionary *)graphQLMetadata {
    return self.metadata.parameters;
}

- (NSDictionary *)metaParametersWithParameters:(NSDictionary *)parameters forHTTPType:(BTAPIClientHTTPType)httpType {
    if (httpType == BTAPIClientHTTPTypeBraintreeAPI) {
        return parameters;
    }

    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (httpType == BTAPIClientHTTPTypeGraphQLAPI) {
        mutableParameters[@"clientSdkMetadata"] = [self graphQLMetadata];
    } else if (httpType == BTAPIClientHTTPTypeGateway) {
        mutableParameters[@"_meta"] = [self metaParameters];
    }

    return [mutableParameters copy];
}

#pragma mark - HTTP Operations

- (void)GET:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self GET:endpoint parameters:parameters httpType:BTAPIClientHTTPTypeGateway completion:completionBlock];
}

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self POST:endpoint parameters:parameters httpType:BTAPIClientHTTPTypeGateway completion:completionBlock];
}

- (void)GET:(NSString *)endpoint parameters:(NSDictionary *)parameters httpType:(BTAPIClientHTTPType)httpType completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration * _Nullable configuration, __unused NSError * _Nullable error) {
        if (error != nil) {
            completionBlock(nil, nil, error);
            return;
        }

        [[self httpForType:httpType] GET:endpoint parameters:parameters completion:completionBlock];
    }];
}

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters httpType:(BTAPIClientHTTPType)httpType completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration * _Nullable configuration, __unused NSError * _Nullable error) {
        if (error != nil) {
            completionBlock(nil, nil, error);
            return;
        }

        NSDictionary *postParameters = [self metaParametersWithParameters:parameters forHTTPType:httpType];
        [[self httpForType:httpType] POST:endpoint parameters:postParameters completion:completionBlock];
    }];
}

- (BTHTTP *)httpForType:(BTAPIClientHTTPType)httpType {
    if (httpType == BTAPIClientHTTPTypeBraintreeAPI) {
        return self.braintreeAPI;
    } else if (httpType == BTAPIClientHTTPTypeGraphQLAPI) {
        return self.graphQL;
    }
    return self.http;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc
{
    if (self.http && self.http.session) {
        [self.http.session finishTasksAndInvalidate];
    }

    if (self.braintreeAPI && self.braintreeAPI.session) {
        [self.braintreeAPI.session finishTasksAndInvalidate];
    }

    if (self.graphQL && self.graphQL.session) {
        [self.graphQL.session finishTasksAndInvalidate];
    }
}

@end
