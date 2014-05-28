#import "BTHTTPResponse.h"

@interface BTHTTPResponse ()

@property (nonatomic, readwrite, strong) NSDictionary *object;
@property (nonatomic, readwrite, assign) NSInteger statusCode;
@end

@implementation BTHTTPResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(NSDictionary *)object {
    self = [self init];
    if (self) {
        self.statusCode = statusCode;
        self.object = object;
    }
    return self;
}

- (BOOL)isSuccess {
    return self.statusCode >= 200 && self.statusCode < 300;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BTHTTPResponse statusCode:%d body:%@>", (int)self.statusCode, self.object];
}

@end
