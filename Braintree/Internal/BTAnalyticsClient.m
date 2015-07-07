//
//  BTAnalyticsClient.m
//  Braintree
//
//  Created by pair on 6/30/15.
//
//

#import "BTAnalyticsClient.h"

#import "BTAPIClient_Internal.h"
#import "BTAnalyticsMetadata.h"
#import "BTClientMetadata.h"
#import "BTHTTP.h"

@interface BTAnalyticsClient ()
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@implementation BTAnalyticsClient

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    self = [super init];
    if (self) {
        self.apiClient = apiClient;
    }
    return [super init];
}

- (void)postAnalyticsEvent:(NSString *)eventKind {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error){
        if (error) {
            // TODO: log error
            return;
        }

        NSURL *analyticsURL = remoteConfiguration[@"analytics"][@"url"].asURL;
        if (analyticsURL) {
            BTHTTP *analyticsHttp = [[BTHTTP alloc] initWithBaseURL:analyticsURL authorizationFingerprint:self.apiClient.clientKey];

            [analyticsHttp POST:@"/"
                     parameters:@{ @"analytics": @[@{ @"kind": eventKind }],
                                   @"_meta": self.metaParameters }
                     completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                         // TODO
                     }];
        } else {
            // TODO: log
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
