#import "BTUIThemedView.h"

@implementation BTUIThemedView

- (id)init {
  self = [super init];
  if (self) {
    [self setTheme:self.theme];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setTheme:self.theme];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self setTheme:self.theme];
  }
  return self;
}

#pragma mark Lazy Instantiation

- (BTUI *)theme {
    if (_theme == nil) {
      _theme = [BTUI braintreeTheme];
    }
    return _theme;
}

@end
