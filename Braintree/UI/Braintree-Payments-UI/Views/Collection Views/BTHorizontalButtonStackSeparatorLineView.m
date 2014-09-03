#import "BTHorizontalButtonStackSeparatorLineView.h"

@implementation BTHorizontalButtonStackSeparatorLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height/2.0f/2.0f, frame.size.width, frame.size.height/2.0f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
    }
    return self;
}

@end
