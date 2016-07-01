#import "BTKBarButtonItem.h"
#import "BTKAppearance.h"

@implementation BTKBarButtonItem

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [BTKAppearance sharedInstance].tintColor, NSFontAttributeName:[UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]} forState:UIControlStateNormal];

    } else {
        [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [BTKAppearance sharedInstance].disabledColor, NSFontAttributeName:[UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]} forState:UIControlStateNormal];
    }
}

@end
