#import "BTUIFormField_Protected.h"
#import "BTUIViewUtil.h"
#import "BTUITextField.h"

#import <QuartzCore/QuartzCore.h>

@interface BTUIFormField ()<BTUITextFieldEditDelegate>

@property (nonatomic, copy) NSString *previousTextFieldText;

@end

@implementation BTUIFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.displayAsValid = YES;
        // Create textField
        BTUITextField *textField = [BTUITextField new];
        textField.editDelegate = self;
        _textField = textField;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.backgroundColor = [UIColor clearColor];
        [self.textField addTarget:self action:@selector(fieldContentDidChange) forControlEvents:UIControlEventEditingChanged];

        self.textField.delegate = self;
        [self addSubview:self.textField];

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
    return CGSizeMake(UIViewNoIntrinsicMetric, 48);
}

- (void)updateConstraints {
    // Set up textField constraints
    NSDictionary *metrics = @{@"horizontalMargin": @([self.theme horizontalMargin])};
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithDictionary:@{@"textField": self.textField}];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(1)-[textField]|" options:0 metrics:metrics views:views]];

    if (self.accessoryView != nil) {
        views[@"accessoryView"] = self.accessoryView;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[textField]-(horizontalMargin)-[accessoryView]-(horizontalMargin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[accessoryView(28)]" options:0 metrics:metrics views:views]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[textField]-(horizontalMargin)-|" options:0 metrics:metrics views:views]];
    }

    [super updateConstraints];
}

- (void)didDeleteBackward {
    NSLog(@"didDeleteBackward: %@ %@", self.previousTextFieldText, self.textField.text);
    if (self.previousTextFieldText.length == 0 && self.textField.text.length == 0) {
        NSLog(@"Empty delete: %@", self.textField.text);
        [self.delegate formFieldDidDeleteWhileEmpty:self];
    }
}

#pragma mark - BTUITextFieldEditDelegate methods

- (void)textFieldWillDeleteBackward:(__unused BTUITextField *)textField {
    _backspace = YES;
}

- (void)textFieldDidDeleteBackward:(__unused BTUITextField *)textField originalText:(NSString *)originalText {
    if (originalText.length == 0) {
        [self.delegate formFieldDidDeleteWhileEmpty:self];
    }
}

- (void)textField:(__unused BTUITextField *)textField willInsertText:(__unused NSString *)text {
    _backspace = NO;
}

#pragma mark - Delegate methods and handlers

- (void)fieldContentDidChange {
    // To be implemented by subclass
}

- (BOOL)textField:(__unused UITextField *)textField shouldChangeCharactersInRange:(__unused NSRange)range replacementString:(__unused NSString *)newText {
    // To be implemented by subclass
    return YES;
}

- (void)textFieldDidBeginEditing:(__unused UITextField *)textField {
    // To be implemented by subclass
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField {
    // To be implemented by subclass
}


@end

