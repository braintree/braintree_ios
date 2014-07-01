#import <Foundation/Foundation.h>

@interface BTDropInErrorAlert : NSObject

- (instancetype)initWithError:(NSError *)error cancel:(void (^)(NSError *error))cancelBlock retry:(void (^)(void))retryBlock;

- (void)show;

@end
