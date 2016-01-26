#import "BTAnalyticsMetadata.h"
#import "BTAnalyticsService.h"
#import "BTClientMetadata.h"
#import "BTLogger_Internal.h"

@interface BTAnalyticsService ()
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@implementation BTAnalyticsService

NSString * const BTAnalyticsServiceErrorDomain = @"com.braintreepayments.BTAnalyticsServiceErrorDomain";

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

#pragma mark - Analytics

- (void)sendAnalyticsEvent:(NSString *)eventKind {
    [self sendAnalyticsEvent:eventKind completion:nil];
}

- (void)sendAnalyticsEvent:(NSString *)eventKind completion:(void(^)(NSError *error))completionBlock {
    long timestampInSeconds = round([[NSDate date] timeIntervalSince1970]);

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error){
        if (error) {
            [[BTLogger sharedLogger] warning:[NSString stringWithFormat:@"Failed to send analytics event. Remote configuration fetch failed. %@", error.localizedDescription]];
            if (completionBlock) completionBlock(error);
            return;
        }

        NSURL *analyticsURL = [configuration.json[@"analytics"][@"url"] asURL];
        if (analyticsURL) {
            if (!self.http) {
                if (self.apiClient.clientToken) {
                    self.http = [[BTHTTP alloc] initWithBaseURL:analyticsURL authorizationFingerprint:self.apiClient.clientToken.authorizationFingerprint];
                } else if (self.apiClient.tokenizationKey) {
                    self.http = [[BTHTTP alloc] initWithBaseURL:analyticsURL tokenizationKey:self.apiClient.tokenizationKey];
                }
                NSAssert(self.http != nil, @"Must have clientToken or tokenizationKey");
                self.http.dispatchQueue = dispatch_get_main_queue();
            }
            // A special value passed in by unit tests to prevent BTHTTP from actually posting
            if ([self.http.baseURL isEqual:[NSURL URLWithString:@"test://do-not-send.url"]]) {
                if (completionBlock) completionBlock(nil);
                return;
            }

            NSMutableDictionary *parameters = [@{ @"analytics": @[@{ @"kind": eventKind,
                                                                     @"timestamp": @(timestampInSeconds)}],
                                                  @"_meta": self.metaParameters } mutableCopy];
            if (self.apiClient.clientToken.authorizationFingerprint) {
                parameters[@"authorization_fingerprint"] = self.apiClient.clientToken.authorizationFingerprint;
            }
            if (self.apiClient.tokenizationKey) {
                parameters[@"tokenization_key"] = self.apiClient.tokenizationKey;
            }
            [self.http POST:@"/"
                          parameters:parameters
                          completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                              if (completionBlock) completionBlock(error);
                          }];
        } else {
            [[BTLogger sharedLogger] debug:@"Skipping sending analytics event - analytics is disabled in remote configuration"];
            NSError *error = [NSError errorWithDomain:BTAnalyticsServiceErrorDomain code:BTAnalyticsServiceErrorTypeMissingAnalyticsURL userInfo:@{NSLocalizedDescriptionKey: @"Missing analytics URL: analytics is disabled in remote configuration"}];
            if (completionBlock) completionBlock(error);
        }
    }];
}

- (NSDictionary *)metaParameters {
    BTClientMetadata *clientMetadata = self.apiClient.metadata;
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

@end
