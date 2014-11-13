#import "BTUIThemedView.h"

@implementation BTUIThemedView

#pragma mark Lazy Instantiation

- (BTUI *)theme {
  if (_theme == nil) {
    _theme = [BTUI braintreeTheme];
  }
  return _theme;
}

@end
