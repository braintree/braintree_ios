#import "BTUIKCardVectorArtView.h"

@implementation BTUIKCardVectorArtView

- (id)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(45.0f, 29.0f);
        self.opaque = NO;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

@end
