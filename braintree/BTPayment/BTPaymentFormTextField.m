#import "BTPaymentFormTextField.h"

#define BT_DEFAULT_TEXT_COLOR [UIColor colorWithWhite:51/255.0f alpha:1]

@implementation BTPaymentFormTextField

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.delegate = delegate;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.font = [UIFont boldSystemFontOfSize:17];
        self.backgroundColor = [UIColor clearColor];

        self.defaultTextColor = BT_DEFAULT_TEXT_COLOR;
        [self resetTextColor];
    }
    return self;
}

- (void)resetTextColor {
    self.textColor = self.defaultTextColor;
}

@end
