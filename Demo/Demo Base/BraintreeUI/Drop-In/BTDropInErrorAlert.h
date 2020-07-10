#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTDropInErrorAlert : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) void (^retryBlock)(void);
@property (nonatomic, copy, nullable) void (^cancelBlock)(void);
@property (nonatomic, weak, nullable) UIViewController *presentingViewController;

- (instancetype)initWithPresentingViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithPresentingViewController:")));

- (void)showWithDismissalHandler:(void (^)(void))dismissalHandler;

@end

NS_ASSUME_NONNULL_END
