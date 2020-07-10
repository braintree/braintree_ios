#import <UIKit/UIKit.h>

@class BTUI, BTUIPayPalWordmarkVectorArtView;

/**
 Represents a PayPal button
 */
@interface BTUIPayPalButton : UIControl

@property (nonatomic, strong) BTUI *theme;

@property (nonatomic, strong) BTUIPayPalWordmarkVectorArtView *payPalWordmark;

@end
