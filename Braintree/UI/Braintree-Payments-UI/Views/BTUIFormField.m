#import "BTUIFormField_Protected.h"
#import "BTUIViewUtil.h"
#import "BTUITextField.h"

#import <QuartzCore/QuartzCore.h>

@interface BTUIFormField ()<BTUITextFieldEditDelegate>

@property (nonatomic, strong) UILabel *floatLabel;
@property (nonatomic, copy) NSString *previousTextFieldText;

@end

@implementation BTUIFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.displayAsValid = YES;
        BTUITextField *textField = [BTUITextField new];
        textField.editDelegate = self;
        _textField = textField;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.backgroundColor = [UIColor clearColor];
        [self.textField addTarget:self action:@selector(fieldContentDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.textField addTarget:self action:@selector(editingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
        [self.textField addTarget:self action:@selector(editingDidEnd) forControlEvents:UIControlEventEditingDidEnd];

        self.textField.delegate = self;

        self.floatLabel = [[UILabel alloc] init];
        [self.floatLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.floatLabel.font = self.theme.textFieldFloatLabelFont;
        self.floatLabel.textColor = self.theme.textFieldFloatLabelTextColor;
        self.floatLabel.alpha = 0.0f;

        [self addSubview:self.textField];
        [self addSubview:self.floatLabel];

        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        self.opaque = NO;

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)setAccessoryView:(UIView *)accessoryView {
    _accessoryView = accessoryView;
    self.accessoryView.userInteractionEnabled = NO;
}

- (void)setDisplayAsValid:(BOOL)displayAsValid {
    if (self.vibrateOnInvalidInput && self.textField.isFirstResponder && _displayAsValid && !displayAsValid) {
        [BTUIViewUtil vibrate];
    }

    _displayAsValid = displayAsValid;
    [self updateAppearance];
    [self setNeedsDisplay];
}

- (void)orientationChange {
    [self setNeedsDisplay];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Validity "abstract" methods

- (BOOL)valid {
    return YES;
}

- (BOOL)entryComplete {
    NSUInteger index = [self.textField offsetFromPosition:self.textField.beginningOfDocument toPosition:self.textField.selectedTextRange.start];
    return index == self.textField.text.length && self.valid;
}

- (void)becomeFirstResponder {
    [self.textField becomeFirstResponder];
}

#pragma mark - Theme

- (void)setTheme:(BTUI *)theme {
    [super setTheme:theme];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:self.theme.textFieldTextAttributes];
    d[NSKernAttributeName] = @0;
    self.textField.defaultTextAttributes = self.theme.textFieldTextAttributes;
}

- (void)setThemedPlaceholder:(NSString *)placeholder {
    self.floatLabel.text = placeholder;
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                           attributes:self.theme.textFieldPlaceholderAttributes];
}

#pragma mark - Drawing

- (void)updateAppearance {
    UIColor *textColor;
    if (!self.displayAsValid){
        textColor = self.theme.errorForegroundColor;
        self.backgroundColor = self.theme.errorBackgroundColor;
    } else {
        textColor = self.theme.textFieldTextColor;
        self.backgroundColor = [UIColor clearColor];
    }

    NSMutableAttributedString *mutableText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textField.attributedText];
    [mutableText addAttributes:@{NSForegroundColorAttributeName: textColor} range:NSMakeRange(0, mutableText.length)];

    UITextRange *currentRange = self.textField.selectedTextRange;

    self.textField.attributedText = mutableText;

    // Reassign current selection range, since it gets cleared after attributedText assignment
    self.textField.selectedTextRange = currentRange;
}

- (void)drawRect:(CGRect)rect {

    // Draw borders

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.displayAsValid) {
        [self.theme.errorForegroundColor setFill];

        CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x, CGRectGetMaxY(rect) - 0.5f, rect.size.width, 0.5f), NULL);
        CGContextAddPath(context, path);
        path = CGPathCreateWithRect(CGRectMake(rect.origin.x, 0, rect.size.width, 0.5f), NULL);
        CGContextAddPath(context, path);

        CGContextDrawPath(context, kCGPathFill);
        CGPathRelease(path);
    } else if (self.bottomBorder) {
        CGFloat horizontalMargin = [self.theme horizontalMargin];
        CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x + horizontalMargin, CGRectGetMaxY(rect) - 0.5f, rect.size.width - horizontalMargin, 0.5f), NULL);
        CGContextAddPath(context, path);
        [self.theme.borderColor setFill];
        CGContextDrawPath(context, kCGPathFill);
        CGPathRelease(path);
    }
}

- (CGSize)intrinsicContentSize {
    // TODO - determine height prorammatically from text size
    return CGSizeMake(UIViewNoIntrinsicMetric, 50);
}

- (void)updateConstraints {
    // Set up textField constraints
    NSDictionary *metrics = @{@"horizontalMargin": @([self.theme horizontalMargin])};
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithDictionary:@{@"textField": self.textField, @"floatLabel": self.floatLabel}];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[floatLabel]-(horizontalMargin)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(6)-[floatLabel]-(2)-[textField]" options:0 metrics:metrics views:views]];

    if (self.accessoryView != nil) {
        views[@"accessoryView"] = self.accessoryView;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[textField]-(horizontalMargin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.accessoryView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accessoryView(==43.5)]-(horizontalMargin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[accessoryView(==27.5)]" options:0 metrics:metrics views:views]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[textField]-(horizontalMargin)-|" options:0 metrics:metrics views:views]];
    }

    [super updateConstraints];
}

- (void)didDeleteBackward {
    if (self.previousTextFieldText.length == 0 && self.textField.text.length == 0) {
        [self.delegate formFieldDidDeleteWhileEmpty:self];
    }
}

#pragma mark - BTUITextFieldEditDelegate methods

- (void)textFieldDidBeginEditing:(__unused UITextField *)textField {
    self.floatLabel.textColor = self.tintColor;
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField {
    self.floatLabel.textColor = self.theme.textFieldFloatLabelTextColor;
}

- (void)textFieldWillDeleteBackward:(__unused BTUITextField *)textField {
    _backspace = YES;
}

- (void)textFieldDidDeleteBackward:(__unused BTUITextField *)textField originalText:(NSString *)originalText {
    if (originalText.length == 0) {
        [self.delegate formFieldDidDeleteWhileEmpty:self];
    }

    if (textField.text.length == 0) {
       [UIView animateWithDuration:0.2f
                             delay:0.0f
                           options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                        animations:^{
                            self.floatLabel.alpha = 0.0f;
                        }
                        completion:nil];
    }
}

- (void)textField:(__unused BTUITextField *)textField willInsertText:(__unused NSString *)text {
    if (textField.text.length == 0 && text.length > 0) {
        [UIView animateWithDuration:0.2f
                             delay:0.0f
                           options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.floatLabel.alpha = 1.0f;
                         }
                         completion:nil];
    }

    _backspace = NO;
}

- (void)setAccessoryHighlighted:(BOOL)highlight {
    if (self.accessoryView) {
        if ([self.accessoryView respondsToSelector:@selector(setHighlighted:animated:)]) {
            SEL selector = @selector(setHighlighted:animated:);
            BOOL animated = YES;
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.accessoryView methodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:self.accessoryView];
            [invocation setArgument:&highlight atIndex:2];
            [invocation setArgument:&animated atIndex:3];
            [invocation invoke];
        }
    }
}

#pragma mark - Delegate methods and handlers

- (void)fieldContentDidChange {
    // To be implemented by subclass
}

- (void)editingDidBegin {
    [self setAccessoryHighlighted:YES];
}

- (void)editingDidEnd {
    [self setAccessoryHighlighted:NO];
}


- (BOOL)textField:(__unused UITextField *)textField shouldChangeCharactersInRange:(__unused NSRange)range replacementString:(__unused NSString *)newText {
    // To be implemented by subclass
    return YES;
}

@end

