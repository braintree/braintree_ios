#import <UIKit/UIKit.h>

@class BTPaymentMethod;

@interface BraintreeDemoBaseViewController : UIViewController

- (instancetype)initWithClientToken:(NSString *)clientToken NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) void (^progressBlock)(NSString *newStatus);
@property (nonatomic, weak) void (^completionBlock)(id paymentMethodOrNonce);

@end
