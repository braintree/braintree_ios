#import "BTConfiguration_Internal.h"

NSString *const BTConfigurationErrorDomain = @"com.braintreepayments.BTConfigurationErrorDomain";

@interface BTConfiguration ()
@property (nonatomic, strong) dispatch_queue_t configurationQueue;
@property (nonatomic, strong) BTJSON *cachedRemoteConfiguration;
@end

@implementation BTConfiguration

- (instancetype)initWithClientKey:(NSString *)clientKey error:(NSError **)error {
    return [self initWithClientKey:clientKey dispatchQueue:nil error:error];
}

- (instancetype)initWithClientKey:(NSString *)clientKey dispatchQueue:(dispatch_queue_t)dispatchQueue error:(NSError **)error {
    NSURL *baseURL = [self baseURLFromClientKey:clientKey error:error];
    if (!baseURL) {
        return nil;
    }

    self = [super init];
    if (self) {
        _clientMetadata = [[BTClientMetadata alloc] init];
        self.clientApiHTTP = [[BTHTTP alloc] initWithBaseURL:baseURL
                                    authorizationFingerprint:clientKey];

        if (dispatchQueue) {
            self.clientApiHTTP.dispatchQueue = dispatchQueue;
        }
        self.configurationQueue = dispatch_queue_create("com.braintreepayments.BTConfiguration", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (dispatch_queue_t)dispatchQueue {
    return self.clientApiHTTP.dispatchQueue ?: dispatch_get_main_queue();
}

#pragma mark - Base URL

- (NSURL *)baseURLFromClientKey:(NSString *)clientKey error:(NSError **)error {
    // TODO: check length of client key, return error if 0

    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z0-9]+)_[a-zA-Z0-9]+_([a-zA-Z0-9_]+)" options:0 error:error];

    NSArray *results = [regExp matchesInString:clientKey options:0 range:NSMakeRange(0, clientKey.length)];

    if (results.count != 1 || [[results firstObject] numberOfRanges] != 3) {
        if (error) {
            *error = [NSError errorWithDomain:@"BTConfigurationErrorDomain" code:1 userInfo:nil]; // TODO: Flesh out this error
        }
        return nil;
    }

    NSString *environment = [clientKey substringWithRange:[results[0] rangeAtIndex:1]];
    NSString *merchantID = [clientKey substringWithRange:[results[0] rangeAtIndex:2]];

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = [self hostForEnvironmentString:environment];
    components.path = [self clientApiBasePathForMerchantID:merchantID];

    return components.URL;
}

- (NSString *)hostForEnvironmentString:(NSString *)environment {
    if ([[environment lowercaseString] isEqualToString:@"sandbox"]) {
        return @"sandbox.braintreegateway.com";
    } else if ([[environment lowercaseString] isEqualToString:@"production"]) {
        return @"braintreegateway.com";
    } else {
        return nil;
    }
}

- (NSString *)clientApiBasePathForMerchantID:(NSString *)merchantID {
    if (merchantID.length == 0) {
        return nil;
    }

    return [NSString stringWithFormat:@"/merchants/%@/client_api", merchantID];
}

#pragma mark - Remote Configuration

- (void)fetchOrReturnRemoteConfiguration:(void (^)(BTJSON *, NSError *))completionBlock {
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
            [self.clientApiHTTP GET:@"v1/configuration" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                if (error) {
                    fetchError = error;
                } else if (response.statusCode != 200) {
                    NSError *configurationDomainError =
                    [NSError errorWithDomain:BTConfigurationErrorDomain
                                        code:BTConfigurationErrorCodeConfigurationUnavailable
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

        dispatch_async(self.dispatchQueue, ^{
            completionBlock(self.cachedRemoteConfiguration, fetchError);
        });
    });
}

@end
