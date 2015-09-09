#import "BTNullability.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTDropInErrorAlert : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, BT_NULLABLE) NSString *message;
@property (nonatomic, copy, BT_NULLABLE) void (^retryBlock)();
@property (nonatomic, copy, BT_NULLABLE) void (^cancelBlock)();
@property (nonatomic, weak, BT_NULLABLE) UIViewController *presentingViewController;

- (instancetype)initWithPresentingViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithPresentingViewController:")));

- (void)show;

@end

NS_ASSUME_NONNULL_END
