#import "BTDropInUIUtilities.h"

@implementation BTDropInUIUtilities

+ (UIView *)addSpacerToStackView:(UIStackView*)stackView beforeView:(UIView*)view size:(float)size {
    NSInteger indexOfView = [stackView.arrangedSubviews indexOfObject:view];
    if (indexOfView != NSNotFound) {
        UIView *spacer = [[UIView alloc] init];
        spacer.translatesAutoresizingMaskIntoConstraints = NO;
        [stackView insertArrangedSubview:spacer atIndex:indexOfView];
        NSLayoutConstraint *heightConstraint = [spacer.heightAnchor constraintEqualToConstant:size];
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        heightConstraint.active = true;
        return spacer;
    }
    return nil;
}

+ (UIStackView *)newStackView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis  = UILayoutConstraintAxisVertical;
    stackView.distribution  = UIStackViewDistributionFill;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 0;
    return stackView;
}

+ (UIStackView *)newStackViewForError:(NSString*)errorText {
    UIStackView *newStackView = [self newStackView];
    UILabel *errorLabel = [UILabel new];
    errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [BTUIKAppearance styleSmallLabelPrimary:errorLabel];
    errorLabel.textColor = [BTUIKAppearance sharedInstance].errorForegroundColor;
    errorLabel.text = errorText;
    newStackView.layoutMargins = UIEdgeInsetsMake([BTUIKAppearance verticalFormSpaceTight], [BTUIKAppearance horizontalFormContentPadding], [BTUIKAppearance verticalFormSpaceTight], [BTUIKAppearance horizontalFormContentPadding]);
    newStackView.layoutMarginsRelativeArrangement = true;
    [newStackView addArrangedSubview:errorLabel];
    return newStackView;
}

@end
