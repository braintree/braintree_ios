#import "BTKInputAccessoryToolbar.h"
#import <UIKit/UIKit.h>
#import "UIColor+BTK.h"

@implementation BTKInputAccessoryToolbar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.barStyle = UIBarStyleDefault;
        self.translucent = YES;
        // TODO David, do we want this hardcoded?
        self.barTintColor = [UIColor BTK_colorFromHex:@"FFFFFF" alpha:0.88];
        self.tintColor = [UIColor BTK_colorFromHex:@"858E99" alpha:1.0];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (instancetype)initWithDoneButtonForInput:(id <UITextInput>)input {
    if (self = [self init]) {
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:input action:@selector(endEditing:)];
        self.items = @[flexSpace, doneButton];
    }
    return self;
}

@end
