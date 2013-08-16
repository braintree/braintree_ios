#import "BTPaymentSectionHeaderView.h"
#import "BTDefines.h"

@interface BTPaymentSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BTPaymentSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = BT_APP_TEXT_COLOR;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);

        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

- (void)setTitleText:(NSString *)text {
    self.titleLabel.text = text;
}

- (void)setIsTopSectionHeader:(BOOL)isTopSectionHeader {
    CGRect selfFrame = self.frame;
    selfFrame.size.height = BT_PAYMENT_SECTION_HEADER_VIEW_HEIGHT - (isTopSectionHeader ? 10 : 0);
    self.frame = selfFrame;

    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.origin.y = (isTopSectionHeader ? 10 : 0);
    self.titleLabel.frame = titleLabelFrame;
}

@end
