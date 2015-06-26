#import <Foundation/Foundation.h>
#import "BTAPIResponseParser.h"

@interface BTHTTPResponse : NSObject

@property (nonatomic, readonly, strong) BTAPIResponseParser *object;
@property (nonatomic, readonly, strong) NSDictionary *rawObject;
@property (nonatomic, readonly, assign) NSInteger statusCode;
@property (nonatomic, readonly, assign, getter = isSuccess) BOOL success;

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(NSDictionary *)response;

@end
