#import <Foundation/Foundation.h>

@interface BTDropInErrorAlert : NSObject

@property (nonatomic, copy) NSString *title;

- (instancetype)initWithError:(NSError *)error cancel:(void (^)(NSError *error))cancelBlock retry:(void (^)(void))retryBlock;

- (void)show;

@end
