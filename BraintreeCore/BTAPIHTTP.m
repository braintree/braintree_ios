#import "BTAPIHTTP.h"
#import "BTAPIPinnedCertificates.h"

#define BT_API_VERSION @"2016-10-07"

@interface BTAPIHTTP ()

@property (nonatomic, strong) NSString *accessToken;

@end

@implementation BTAPIHTTP

- (instancetype)initWithBaseURL:(NSURL *)URL accessToken:(NSString *)accessToken {
    if (self = [super initWithBaseURL:URL]) {
        self.accessToken = accessToken;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = self.defaultHeaders;
        
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.name = @"com.braintreepayments.BTHTTP";
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
        self.pinnedCertificates = [BTAPIPinnedCertificates trustedCertificates];
    }
    return self;
}

- (NSDictionary *)defaultHeaders {
        return @{ @"User-Agent": [self userAgentString],
                  @"Accept": [self acceptString],
                  @"Accept-Language": [self acceptLanguageString],
                  @"Braintree-Version": BT_API_VERSION,
                  @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.accessToken]};
}

@end
