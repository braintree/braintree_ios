#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface BTHTTPSpecStubResponseManager : NSObject

- (void)stubResponseWithStatusCode:(int)statusCode
                           pattern:(NSString *)pattern
               responseContentType:(NSString *)contentType;

- (void)stubResponseWithStatusCode:(int)statusCode
                           pattern:(NSString *)pattern
               responseContentType:(NSString *)contentType
                      responseData:(NSData *)data;

- (void)removeAllStubs;

@end
