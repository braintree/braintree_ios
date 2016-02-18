#import "BTAnalyticsMetadata.h"
#import "BTAnalyticsService.h"
#import "BTAPIClient_Internal.h"
#import "BTLogger_Internal.h"
#import "BTClientToken.h"

NSString *const BTAPIClientErrorDomain = @"com.braintreepayments.BTAPIClientErrorDomain";

@interface BTAPIClient ()
@property (nonatomic, strong) dispatch_queue_t configurationQueue;
@property (nonatomic, strong) BTJSON *cachedRemoteConfiguration;
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
        _metadata = [[BTClientMetadata alloc] init];
        _configurationQueue = dispatch_queue_create("com.braintreepayments.BTAPIClient", DISPATCH_QUEUE_SERIAL);


        NSURL *baseURL = [BTAPIClient baseURLFromTokenizationKey:authorization];
        if (baseURL) {
            _tokenizationKey = authorization;

            _http = [[BTHTTP alloc] initWithBaseURL:baseURL tokenizationKey:authorization];

            if (sendAnalyticsEvent) {
                [self sendAnalyticsEvent:@"ios.started.client-key"];
            }
        } else {
            NSError *error;
            _clientToken = [[BTClientToken alloc] initWithClientToken:authorization error:&error];
            if (error) { [[BTLogger sharedLogger] error:[error localizedDescription]]; }
            if (!_clientToken) {
                NSString *reason = @"BTClient could not initialize because the provided clientToken was invalid";
                [[BTLogger sharedLogger] error:reason];
                return nil;
            }

            NSURL *baseURL = [self.clientToken.json[@"clientApiUrl"] asURL];
            _http = [[BTHTTP alloc] initWithBaseURL:baseURL authorizationFingerprint:self.clientToken.authorizationFingerprint];

            if (sendAnalyticsEvent) {
                [self sendAnalyticsEvent:@"ios.started.client-token"];
            }
        }
    }
    return self;
}

- (instancetype)copyWithSource:(BTClientMetadataSourceType)source
                   integration:(BTClientMetadataIntegrationType)integration
{
    BTAPIClient *copiedClient;

    if (self.clientToken) {
        copiedClient = [[[self class] alloc] initWithAuthorization:self.clientToken.originalValue sendAnalyticsEvent:NO];
    } else if (self.tokenizationKey) {
        copiedClient = [[[self class] alloc] initWithAuthorization:self.tokenizationKey sendAnalyticsEvent:NO];
    } else {
        NSAssert(NO, @"Cannot copy an API client that does not specify a client token or tokenization key");
    }

    copiedClient.http = [self.http copy];
    copiedClient.cachedRemoteConfiguration = self.cachedRemoteConfiguration;

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
    NSArray *hostComponents = [host componentsSeparatedByString:@":"];
    components.host = hostComponents[0];
    if (hostComponents.count > 1) {
        components.port = hostComponents[1];
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
        return @"sandbox.braintreegateway.com";
    } else if ([[environment lowercaseString] isEqualToString:@"production"]) {
        return @"api.braintreegateway.com:443";
    } else if ([[environment lowercaseString] isEqualToString:@"development"]) {
        return @"localhost:3000";
    } else {
        return nil;
    }
}

+ (NSString *)clientApiBasePathForMerchantID:(NSString *)merchantID {
    if (merchantID.length == 0) {
        return nil;
    }

    return [NSString stringWithFormat:@"/merchants/%@/client_api", merchantID];
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

        if (self.cachedRemoteConfiguration == nil) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self.http GET:@"v1/configuration" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
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
                    self.cachedRemoteConfiguration = body;
                }

                // Important: Unlock semaphore in all cases
                dispatch_semaphore_signal(semaphore);
            }];

            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            BTConfiguration *configuration;
            if (self.cachedRemoteConfiguration) {
                configuration = [[BTConfiguration alloc] initWithJSON:self.cachedRemoteConfiguration];
            }
            completionBlock(configuration, fetchError);
        });
    });
}

#pragma mark - Analytics

@synthesize analyticsService = _analyticsService;

/// By default, the `BTAnalyticsService` instance is static/shared so that only one queue of events exists.
/// The "singleton" is managed here because the analytics service depends on `BTAPIClient`.
- (BTAnalyticsService *)analyticsService {
    static BTAnalyticsService *analyticsService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:self];
        analyticsService.flushThreshold = 5;
    });
    if (_analyticsService) return _analyticsService;
    return analyticsService;
}

// The analytics service may be overridden by unit tests
- (void)setAnalyticsService:(BTAnalyticsService *)analyticsService {
    _analyticsService = analyticsService;
}

- (void)sendAnalyticsEvent:(NSString *)eventKind {
    [self.analyticsService sendAnalyticsEvent:eventKind];
}

- (NSDictionary *)metaParameters {
    BTClientMetadata *clientMetadata = self.metadata;
    NSMutableDictionary *clientMetadataParameters = [NSMutableDictionary dictionary];
    clientMetadataParameters[@"integration"] = clientMetadata.integrationString;
    clientMetadataParameters[@"source"] = clientMetadata.sourceString;
    clientMetadataParameters[@"sessionId"] = clientMetadata.sessionId;

    NSDictionary *analyticsMetadata = [BTAnalyticsMetadata metadata];

    NSMutableDictionary *metaParameters = [NSMutableDictionary dictionary];
    [metaParameters addEntriesFromDictionary:analyticsMetadata];
    [metaParameters addEntriesFromDictionary:clientMetadataParameters];

    return [metaParameters copy];
}

#pragma mark - HTTP Operations

- (void)GET:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self.http GET:endpoint parameters:parameters completion:completionBlock];
}

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"_meta"] = [self metaParameters];
    [mutableParameters addEntriesFromDictionary:parameters];
    [self.http POST:endpoint parameters:mutableParameters completion:completionBlock];

}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

@end
