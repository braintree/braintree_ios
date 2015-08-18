#import <UIKit/UIKit.h>
#import <BraintreeCore/BraintreeCore.h>

@interface BraintreeDemoBaseViewController : UIViewController

- (instancetype)initWithClientToken:(NSString *)clientToken NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithClientKey:(NSString *)clientKey NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) void (^progressBlock)(NSString *newStatus);
@property (nonatomic, weak) void (^completionBlock)(id<BTTokenized> tokenization);

@end
