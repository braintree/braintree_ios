#import "BTHorizontalButtonStackSeparatorLineView.h"

@interface BTHorizontalButtonStackSeparatorLineView ()
@property (nonatomic, strong) UIView *line;
@end

@implementation BTHorizontalButtonStackSeparatorLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];

        self.line = [[UIView alloc] initWithFrame:CGRectZero];
        self.line.translatesAutoresizingMaskIntoConstraints = NO;
        self.line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.line];
    }
    return self;
}

- (void)updateConstraints {
    NSDictionary *views = @{ @"line": self.line };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[line]|"
                                                                options:0
                                                                metrics:nil
                                                                  views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.line
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:2.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.line
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [super updateConstraints];
}

@end
