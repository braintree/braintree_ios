#import "BTFakeHTTP.h"

@implementation BTFakeHTTP

- (nullable instancetype)init {
    return [self initWithBaseURL:[[NSURL alloc] init] authorizationFingerprint:@""];
}

+ (instancetype)fakeHTTP {
    return [[BTFakeHTTP alloc] initWithBaseURL:[[NSURL alloc] init] authorizationFingerprint:@""];
}

- (void)stubRequest:(NSString *)httpMethod toEndpoint:(NSString *)endpoint respondWith:(id)value statusCode:(NSUInteger)statusCode {
    self.stubMethod = httpMethod;
    self.stubEndpoint = endpoint;
    self.cannedResponse = [[BTJSON alloc] initWithValue:value];
    self.cannedStatusCode = statusCode;
}

- (void)stubRequest:(NSString *)httpMethod toEndpoint:(NSString *)endpoint respondWithError:(NSError *)error {
    self.stubMethod = httpMethod;
    self.stubEndpoint = endpoint;
    self.cannedError = error;
}

- (void)GET:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *, NSHTTPURLResponse *, NSError *))completionBlock {
    self.GETRequestCount++;
    self.lastRequestEndpoint = endpoint;
    self.lastRequestParameters = parameters;
    
    if (self.cannedError) {
        [self dispatchBlock:^{
            completionBlock(nil, nil, self.cannedError);
        }];
    } else {
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:endpoint]
                                                                      statusCode:self.cannedStatusCode
                                                                     HTTPVersion:nil
                                                                    headerFields:nil];
        [self dispatchBlock:^{
            completionBlock(self.cannedResponse, httpResponse, nil);
        }];
    }
}

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void (^)(BTJSON *, NSHTTPURLResponse *, NSError *))completionBlock {
    self.POSTRequestCount++;
    self.lastRequestEndpoint = endpoint;
    self.lastRequestParameters = parameters;
    
    if (self.cannedError) {
        [self dispatchBlock:^{
            completionBlock(nil, nil, self.cannedError);
        }];
    } else {
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:endpoint]
                                                                      statusCode:self.cannedStatusCode
                                                                     HTTPVersion:nil
                                                                    headerFields:nil];
        [self dispatchBlock:^{
            completionBlock(self.cannedResponse, httpResponse, nil);
        }];
    }
}

/// Helper method to dispatch callbacks to dispatchQueue
- (void)dispatchBlock:(void(^)())block {
    if (self.dispatchQueue) {
        dispatch_async(self.dispatchQueue, ^{
            block();
        });
    } else {
        block();
    }
}

@end
