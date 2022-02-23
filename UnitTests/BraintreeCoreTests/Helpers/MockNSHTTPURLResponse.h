#ifndef MockNSHTTPURLResponse_h
#define MockNSHTTPURLResponse_h


@interface MockNSHTTPURLResponse : NSHTTPURLResponse

- (instancetype)init;
- (void)setAllHeaderFields:(NSDictionary *)headers;

@property(nonatomic) NSDictionary *headers;

@end
#endif /* MockNSHTTPURLResponse_h */
