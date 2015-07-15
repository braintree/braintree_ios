#import "BTAnalyticsClient_Internal.h"

#import "BTAPIClient_Internal.h"
#import "BTAnalyticsMetadata.h"
#import "BTClientMetadata.h"
#import "BTHTTP.h"
#import "BTLogger_Internal.h"

@interface BTAnalyticsClient ()
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@implementation BTAnalyticsClient

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

- (void)postAnalyticsEvent:(NSString *)eventKind {
    [self postAnalyticsEvent:eventKind completion:nil];
}

- (void)postAnalyticsEvent:(NSString *)eventKind completion:(void(^)(NSError *error))completionBlock {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error){
        if (error) {
            [[BTLogger sharedLogger] warning:[NSString stringWithFormat:@"Failed to send analytics event. Remote configuration fetch failed. %@", error.localizedDescription]];
            if (completionBlock) completionBlock(error);
            return;
        }

        NSURL *analyticsURL = remoteConfiguration[@"analytics"][@"url"].asURL;
        if (analyticsURL) {
            if (!self.analyticsHttp) {
                self.analyticsHttp = [[BTHTTP alloc] initWithBaseURL:analyticsURL authorizationFingerprint:self.apiClient.clientKey];
            }
            // A special value passed in by unit tests to prevent BTHTTP from actually posting
            if ([self.analyticsHttp.baseURL isEqual:[NSURL URLWithString:@"test://do-not-send.url"]]) {
                if (completionBlock) completionBlock(nil);
                return;
            }

            [self.analyticsHttp POST:@"/"
                          parameters:@{ @"analytics": @[@{ @"kind": eventKind }],
                                        @"_meta": self.metaParameters }
                          completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                              if (completionBlock) completionBlock(error);
                          }];
        } else {
            [[BTLogger sharedLogger] debug:@"Skipping sending analytics event - analytics is disabled in remote configuration"];
            if (completionBlock) completionBlock(nil);
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
