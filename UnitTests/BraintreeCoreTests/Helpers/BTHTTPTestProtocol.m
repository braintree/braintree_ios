#import "BTHTTPTestProtocol.h"
@import BraintreeCore;
@import BraintreeCoreSwift;

@implementation BTHTTPTestProtocol

+ (BOOL)canInitWithRequest:(__unused NSURLRequest *)request {
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = self.client;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{@"Content-Type": @"application/json"}];

    NSData *archivedRequest = [NSKeyedArchiver archivedDataWithRootObject:self.request requiringSecureCoding:YES error:nil];
    NSString *base64ArchivedRequest = [archivedRequest base64EncodedStringWithOptions:0];

    NSData *requestBodyData;
    if (self.request.HTTPBodyStream) {
        NSInputStream *inputStream = self.request.HTTPBodyStream;
        [inputStream open];
        NSMutableData *mutableBodyData = [NSMutableData data];

        while ([inputStream hasBytesAvailable]) {
            uint8_t buffer[128];
            NSUInteger bytesRead = [inputStream read:buffer maxLength:128];
            [mutableBodyData appendBytes:buffer length:bytesRead];
        }
        [inputStream close];
        requestBodyData = [mutableBodyData copy];
    } else {
        requestBodyData = self.request.HTTPBody;
    }

    NSDictionary *responseBody = @{ @"request": base64ArchivedRequest,
                                    @"requestBody": [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding] };

    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    [client URLProtocol:self didLoadData:[NSJSONSerialization dataWithJSONObject:responseBody options:NSJSONWritingPrettyPrinted error:NULL]];

    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

+ (NSURL *)testBaseURL {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kBTHTTPTestProtocolScheme;
    components.host = kBTHTTPTestProtocolHost;
    components.path = kBTHTTPTestProtocolBasePath;
    components.port = kBTHTTPTestProtocolPort;
    return components.URL;
}

+ (NSURLRequest *)parseRequestFromTestResponseBody:(BTJSON *)responseBody {
//    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:[responseBody[@"request"] asString] options:0]];
    NSData *dataToUnarchive = [[NSData alloc] initWithBase64EncodedString:[responseBody[@"request"] asString] options:0];
    return [NSKeyedUnarchiver unarchivedObjectOfClass:NSURLRequest.class fromData:dataToUnarchive error:nil];
}

+ (NSString *)parseRequestBodyFromTestResponseBody:(BTJSON *)responseBody {
    return [responseBody[@"requestBody"] asString];
}

@end

