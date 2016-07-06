#import "BTKFormField.h"
#import "BTKVectorArtView.h"
#import "BTKViewUtil.h"
#import "BTKAppearance.h"

@interface BTKFormField ()<BTKTextFieldEditDelegate>

@property (nonatomic, copy) NSString *previousTextFieldText;
@property (nonatomic, strong) NSMutableArray *layoutConstraints;

@end

@implementation BTKFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [BTKAppearance sharedInstance].formFieldBackgroundColor;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.displayAsValid = YES;
        BTKTextField *textField = [BTKTextField new];
        textField.editDelegate = self;
        _textField = textField;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.opaque = NO;
        self.textField.adjustsFontSizeToFitWidth = YES;
        self.textField.returnKeyType = UIReturnKeyNext;
        [self.textField addTarget:self action:@selector(fieldContentDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.textField addTarget:self action:@selector(editingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
        [self.textField addTarget:self action:@selector(editingDidEnd) forControlEvents:UIControlEventEditingDidEnd];
        self.textField.delegate = self;
        [self addSubview:self.textField];
        
        self.formLabel = [[UILabel alloc] init];
        [BTKAppearance styleSmallLabelPrimary:self.formLabel];
        self.formLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.formLabel.text = @"";
        [self addSubview:self.formLabel];

        [self.formLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.formLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.textField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedField)]];
        
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        self.opaque = NO;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        [self updateConstraints];
    }
    return self;
}

- (void)orientationChange {
    [self setNeedsDisplay];
}

- (void)updateConstraints {
    
    if (self.layoutConstraints != nil) {
        [self removeConstraints:self.layoutConstraints];
    }
    self.layoutConstraints = [NSMutableArray array];
    
    NSMutableDictionary* viewBindings = [@{@"view":self, @"textField":self.textField, @"formLabel": self.formLabel} mutableCopy];
    
    if (self.accessoryView) {
        viewBindings[@"accessoryView"] = self.accessoryView;
    }
    
    NSDictionary* metrics = @{@"PADDING":@10};
    
    BOOL hasFormLabel = (self.formLabel.text.length > 0);
    
    [self.layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewBindings]];

    [self.layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[formLabel]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewBindings]];
    if (hasFormLabel) {
        [self.layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(PADDING)-[formLabel(<=0@1)]-[textField]"
                                                                                            options:0
                                                                                            metrics:metrics
                                                                                              views:viewBindings]];
    } else {
        [self.layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(PADDING)-[textField]"
                                                                                            options:0
                                                                                            metrics:metrics
                                                                                              views:viewBindings]];
    }
    
    if (self.accessoryView && !self.accessoryView.hidden) {
        [self.layoutConstraints addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:self.accessoryView
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                multiplier:1.0f
                                                                                  constant:0.0f]]];
        
      ;
        
        [self.layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textField]-[accessoryView]-(PADDING)-|"
                                                                                            options:0
                                                                                            metrics:metrics
                                                                                              views:viewBindings]];
    } else {
        [self.layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textField]-(PADDING)-|"
                                                                                            options:0
                                                                                            metrics:metrics
                                                                                              views:viewBindings]];
    }

    NSArray *contraintsToAdd = [self.layoutConstraints copy];

    [self addConstraints:contraintsToAdd];
    
    NSTextAlignment newAlignment = hasFormLabel ? [BTKViewUtil naturalTextAlignmentInverse] : [BTKViewUtil naturalTextAlignment];
    if (newAlignment != self.textField.textAlignment) {
        self.textField.textAlignment = newAlignment;
    }

    [super updateConstraints];
}

- (void)textFieldDidBeginEditing:(__unused UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(formFieldDidBeginEditing:)]) {
        [self.delegate formFieldDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(formFieldDidEndEditing:)]) {
        [self.delegate formFieldDidEndEditing:self];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    // Draw borders
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.displayAsValid) {
        [[BTKAppearance sharedInstance].errorForegroundColor setFill];
        
        CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x, CGRectGetMaxY(rect) - 0.5f, rect.size.width, 0.5f), NULL);
        CGContextAddPath(context, path);
        CGPathRelease(path);
        
        path = CGPathCreateWithRect(CGRectMake(rect.origin.x, 0, rect.size.width, 0.5f), NULL);
        CGContextAddPath(context, path);
        
        CGContextDrawPath(context, kCGPathFill);
        CGPathRelease(path);
    } else {
        if (self.interFieldBorder || self.bottomBorder) {
            CGFloat horizontalMargin = self.bottomBorder ? 0 : 17.0f;
            CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x + horizontalMargin, CGRectGetMaxY(rect) - 0.5f, rect.size.width - horizontalMargin, 0.5f), NULL);
            CGContextAddPath(context, path);
            [[BTKAppearance sharedInstance].lineColor setFill];
            CGContextDrawPath(context, kCGPathFill);
            CGPathRelease(path);
        }
        if (self.topBorder) {
            CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x, 0, rect.size.width, 0.5f), NULL);
            CGContextAddPath(context, path);
            [[BTKAppearance sharedInstance].lineColor setFill];
            CGContextDrawPath(context, kCGPathFill);
            CGPathRelease(path);
        }
    }
}

- (void)setBottomBorder:(BOOL)bottomBorder {
    _bottomBorder = bottomBorder;
    [self setNeedsDisplay];
}

- (void)setInterFieldBorder:(BOOL)interFieldBorder {
    _interFieldBorder = interFieldBorder;
    [self setNeedsDisplay];
}

- (void)setTopBorder:(BOOL)topBorder {
    _topBorder = topBorder;
    [self setNeedsDisplay];
}

- (void)updateAppearance {
    UIColor *textColor;
    NSString *currentAccessibilityLabel = self.textField.accessibilityLabel;
    if (!self.displayAsValid){
        textColor = [BTKAppearance sharedInstance].errorForegroundColor;
        self.backgroundColor = [BTKAppearance sharedInstance].errorBackgroundColor;
        if (currentAccessibilityLabel != nil) {
            self.textField.accessibilityLabel = [self addInvalidAccessibilityToString:currentAccessibilityLabel];
        }
    } else {
        textColor = [BTKAppearance sharedInstance].primaryTextColor;
        self.backgroundColor = [BTKAppearance sharedInstance].formFieldBackgroundColor;
        if (currentAccessibilityLabel != nil) {
            self.textField.accessibilityLabel = [self stripInvalidAccessibilityFromString:currentAccessibilityLabel];
        }
    }
    
    NSMutableAttributedString *mutableText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textField.attributedText];
    [mutableText addAttributes:@{NSForegroundColorAttributeName: textColor, NSFontAttributeName:[UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]} range:NSMakeRange(0, mutableText.length)];
    
    UITextRange *currentRange = self.textField.selectedTextRange;
    
    self.textField.attributedText = mutableText;
    
    // Reassign current selection range, since it gets cleared after attributedText assignment
    self.textField.selectedTextRange = currentRange;
}

#pragma mark - BTUITextFieldEditDelegate methods

- (void)textFieldWillDeleteBackward:(__unused BTKFormField *)textField {
    // _backspace indicates that the backspace key was typed.
    _backspace = YES;
    
}

- (void)textFieldDidDeleteBackward:(__unused BTKFormField *)textField originalText:(__unused NSString *)originalText {
    // To be implemented by subclasses
}

- (void)textField:(__unused BTKFormField *)textField willInsertText:(__unused NSString *)text {
    _backspace = NO;
}

- (void)textField:(__unused BTKFormField *)textField didInsertText:(__unused NSString *)text {
    // To be implemented by subclasses
}


#pragma mark - Custom accessors

- (void)setText:( __unused NSString *)text {
    BOOL shouldChange = [self.textField.delegate textField:self.textField
                             shouldChangeCharactersInRange:NSMakeRange(0, self.textField.text.length)
                                         replacementString:text];
    if (shouldChange) {
        // RSS & DM: commented out didBeginEditing/didEndEditing callbacks because they affected the
        // behavior of the expiry input keyboard.
        //[self.textField.delegate textFieldDidBeginEditing:self.textField];
        [self.textField.editDelegate textField:self.textField willInsertText:text];
        self.textField.text = text;
        [self fieldContentDidChange];
        [self.textField.editDelegate textField:self.textField didInsertText:text];
        // See above
        //[self.textField.delegate textFieldDidEndEditing:self.textField];
    }
    [self updateAppearance];
}

- (NSString *)text {
    return self.textField.text;
}

#pragma mark - Delegate methods and handlers

- (void)resetFormField {
    // To be implemented by subclass
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (void)fieldContentDidChange {
    // To be implemented by subclass
    if (self.delegate) {
        [self.delegate formFieldDidChange:self];    
    }
    [self updateAppearance];
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

- (BOOL)textFieldShouldReturn:(__unused UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(formFieldShouldReturn:)]) {
        return [self.delegate formFieldShouldReturn:self];
    } else {
        return YES;
    }
}

- (void)tappedField {
    [self.textField becomeFirstResponder];
}

#pragma mark UIKeyInput

- (void)insertText:(__unused NSString *)text {
    [self.textField insertText:text];
}

- (void)deleteBackward {
    [self.textField deleteBackward];
}

- (BOOL)hasText {
    return [self.textField hasText];
}

#pragma mark Accessibility Helpers

- (NSString *)stripInvalidAccessibilityFromString:(NSString *)str {
    return [str stringByReplacingOccurrencesOfString:@"Invalid: " withString:@""];
}

- (NSString *)addInvalidAccessibilityToString:(NSString *)str {
    return [NSString stringWithFormat:@"Invalid: %@", [self stripInvalidAccessibilityFromString:str]];
}

#pragma mark Accessory View Helpers

- (void)setAccessoryView:(UIView *)accessoryView {
    if (self.accessoryView && self.accessoryView.superview) {
        [self.accessoryView removeFromSuperview];
        _accessoryView = nil;
    }
    _accessoryView = accessoryView;
    self.accessoryView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.accessoryView];
    [self updateConstraints];
}

- (void)setAccessoryViewHidden:(BOOL)hidden animated:(__unused BOOL)animated {
    if (self.accessoryView == nil) {
        [self updateConstraints];
        return;
    }
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.accessoryView.hidden = hidden;
            [self updateConstraints];
        }];
    } else {
        self.accessoryView.hidden = hidden;
        [self updateConstraints];
    }
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

@end
