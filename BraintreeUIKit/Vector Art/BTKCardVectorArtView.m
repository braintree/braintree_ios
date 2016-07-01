#import "BTKCardVectorArtView.h"

@implementation BTKCardVectorArtView

- (id)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(87.0f, 55.0f);
        self.opaque = NO;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

@end
