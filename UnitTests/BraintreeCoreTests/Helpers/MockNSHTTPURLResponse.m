#import <Foundation/Foundation.h>

@interface MockNSHTTPURLResponse : NSHTTPURLResponse { NSDictionary *headers; }
- (void)setAllHeaderFields:(NSDictionary *)dictionary;
@end

@implementation MockNSHTTPURLResponse
- (NSDictionary *)allHeaderFields { return headers ?: [super allHeaderFields]; }
- (void)setAllHeaderFields:(NSDictionary *)dict  {
    headers = dict;
}

@end
