#import <Foundation/Foundation.h>

@interface BTHTTPResponse : NSObject

@property (nonatomic, readonly, strong) NSDictionary *object;
@property (nonatomic, readonly, assign) NSInteger statusCode;
@property (nonatomic, readonly, assign, getter = isSuccess) BOOL success;

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(NSDictionary *)response;

@end