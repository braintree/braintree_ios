#import <UIKit/UIKit.h>
@class BTPaymentMethodNonce;

@interface BraintreeDemoBaseViewController : UIViewController

- (instancetype)initWithAuthorization:(NSString *)authorization NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) void (^progressBlock)(NSString *newStatus);
@property (nonatomic, weak) void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce);
@property (nonatomic, weak) void (^transactionBlock)(void);

@end
