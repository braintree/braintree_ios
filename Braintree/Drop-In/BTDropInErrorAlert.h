#import <Foundation/Foundation.h>

@interface BTDropInErrorAlert : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

- (instancetype)initWithCancel:(void (^)(void))cancelBlock retry:(void (^)(void))retryBlock;

- (void)show;

@end
