#import <UIKit/UIKit.h>

@protocol BTPaymentButtonDelegate;

@interface BTPaymentButton : UIView

@property (nonatomic, weak) id<BTPaymentButtonDelegate> delegate;

@end

@protocol BTPayPalButtonDelegate <NSObject>

- (void)addTarget:action:

@end