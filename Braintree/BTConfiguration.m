#import "BTConfiguration_Internal.h"

NSString *const BTConfigurationErrorDomain = @"com.braintreepayments.BTConfigurationErrorDomain";

@interface BTConfiguration ()
@property (nonatomic, strong) dispatch_queue_t configurationQueue;
@property (nonatomic, strong) BTJSON *cachedRemoteConfiguration;
@end

@implementation BTConfiguration

- (instancetype)initWithClientKey:(NSString *)clientKey {
    return [self initWithClientKey:clientKey dispatchQueue:nil];
}
- (instancetype)initWithClientKey:(NSString *)clientKey dispatchQueue:(dispatch_queue_t)dispatchQueue {
    self = [super init];
    if (self) {
        self.clientKey = clientKey;
        self.configurationHttp = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@""] authorizationFingerprint:self.clientKey];

        if (dispatchQueue) {
            self.configurationHttp.dispatchQueue = dispatchQueue;
        }
        self.configurationQueue = dispatch_queue_create("com.braintreepayments.BTConfiguration", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (dispatch_queue_t)dispatchQueue {
    return self.configurationHttp.dispatchQueue ?: dispatch_get_main_queue();
}

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
            [self.configurationHttp GET:@"/client_api/v1/configuration" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
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
