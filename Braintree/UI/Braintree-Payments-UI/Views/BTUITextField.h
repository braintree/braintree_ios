#import <UIKit/UIKit.h>

@interface BTUITextField : UITextField

@property (nonatomic, copy) void (^deleteBackwardBlock)(NSString *, BTUITextField *);
@property (nonatomic, copy) void (^insertTextBlock)(NSString *, BTUITextField *);

@end
