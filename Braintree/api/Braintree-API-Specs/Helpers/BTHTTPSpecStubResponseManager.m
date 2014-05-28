#import "BTHTTPSpecStubResponseManager.h"

@interface BTHTTPSpecStubResponseManager ()
@end

@implementation BTHTTPSpecStubResponseManager

- (void)stubResponseWithStatusCode:(int)statusCode
                           pattern:(NSString *)pattern
               responseContentType:(NSString *)contentType {
    [self stubResponseWithStatusCode:statusCode
                             pattern:pattern
                 responseContentType:contentType
                        responseData:nil];
}

- (void)stubResponseWithStatusCode:(int)statusCode
                           pattern:(NSString *)pattern
               responseContentType:(NSString *)responseContentType
                      responseData:(NSData *)responseData {

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [self request:request matchesPattern:pattern];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *responseDataForStubResponse = responseData;

        if (!responseDataForStubResponse) {
            if ([pattern isEqualToString:@"network-down"]) {
                return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                                  code:NSURLErrorNotConnectedToInternet
                                                                              userInfo:nil]];
            } else if ([pattern isEqualToString:@"/invalid.json"]) {
                responseDataForStubResponse = [@"@{ invalidJson ]" dataUsingEncoding:NSUTF8StringEncoding];
            } else if ([responseContentType isEqualToString:@"application/json"]) {


                NSString *requestHTTPBody = [request HTTPBody] ? [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] : @"";

                id responseObject = @{@"request": @"ok",
                                      @"status": @(statusCode),
                                      @"pattern": pattern,
                                      @"requestInfo": @{
                                              @"valueForHTTPHeaderField": @{
                                                      @"Content-type": [request valueForHTTPHeaderField:@"Content-type"] ?: [NSNull null]},
                                              @"URL": @{@"path": [request.URL path] ?: [NSNull null],
                                                        @"query": [request.URL query] ?: [NSNull null],
                                                        @"absoluteString": [request.URL absoluteString] ?: [NSNull null]},
                                              @"HTTPMethod": [request HTTPMethod] ?: [NSNull null],
                                              @"HTTPBody": requestHTTPBody}}
                ;
                responseDataForStubResponse = [NSJSONSerialization dataWithJSONObject:responseObject
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil];
            } else if ([responseContentType isEqualToString:@"text/html"]) {
                responseDataForStubResponse = [@"<dl><dt>request</dt><dd>ok</dd> \
                                               <dt>status</dt><dd>statusCode</dd> \
                                               <dt>pattern</dt><dd>pattern</dd>" dataUsingEncoding:NSUTF8StringEncoding];
            }
        }

        return [OHHTTPStubsResponse responseWithData:responseDataForStubResponse
                                          statusCode:statusCode
                                             headers:@{@"Content-type": responseContentType}];
    }];
}

- (void)removeAllStubs {
    [OHHTTPStubs removeAllStubs];
}

#pragma - Internal

- (BOOL)request:(NSURLRequest *)request matchesPattern:(NSString *)pattern {
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(error == NULL, @"Error compiling regex pattern for stub response matcher: %@", error);

    NSString *path = [request.URL path];
    NSUInteger pathMatchesInPattern = [regex numberOfMatchesInString:path options:0 range:NSMakeRange(0, [path length])];
    return (pathMatchesInPattern > 0);
}

@end


