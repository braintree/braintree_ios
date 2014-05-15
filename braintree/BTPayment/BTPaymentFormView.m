#import "BTPaymentFormView.h"
#import "BTPaymentCardUtils.h"

#define BT_REGEX_POSTCODE_UK @"(GIR[ ]?0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY]))))[ ]?[0-9][A-Z-[CIKMOV]]{2})"

#define BT_REGEX_ZIP_USA @"^[0-9][0-9][0-9][0-9][0-9]$"

@interface BTPaymentFormView()
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, copy) NSString *cardImageName;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

static NSInteger thisMonth;
static NSInteger thisYear;

@implementation BTPaymentFormView

// private
@synthesize cardImageView;
@synthesize cardImageName;
@synthesize scrollView;

// public
@synthesize cardNumberTextField;
@synthesize monthYearTextField;
@synthesize cvvTextField;
@synthesize zipTextField;
@synthesize delegate;

// Locate the VDKResources.bundle file to retrieve card and cvv hint images.
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"BraintreeResources.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

+ (UIImage *)imageWithName:(NSString *)name {
    return [UIImage imageWithContentsOfFile:[[self frameworkBundle] pathForResource:name ofType:@"png"]];
}

// Set up date components to check the MM/YY field.
+ (void)initialize {
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                    fromDate:[NSDate date]];
    thisMonth = [components month];
    thisYear  = [components year] - 2000;
}

// Shorthand initializer.
+ (BTPaymentFormView *)paymentFormView {
    return [[BTPaymentFormView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _UKSupportEnabled = NO;

        _scrollOffsetAmex = 271.0f;
        _scrollOffsetGeneric = 300.0f;
        
        // images are 28 x 19
        cardImageName = @"BTGenericCard";
        cardImageView = [[UIImageView alloc] initWithImage:[BTPaymentFormView imageWithName:cardImageName]];
        cardImageView.frame = CGRectMake(10, 10, 28, 19);
        [self addSubview:cardImageView];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(48, 5, 258, 30)];
        scrollView.contentSize     = CGSizeMake(500, 30);
        scrollView.scrollEnabled   = NO;
        [self addSubview:scrollView];
        
        cardNumberTextField = [[BTPaymentFormTextField alloc] initWithFrame:CGRectMake(5, 0, 240, 30) delegate:self];
        cardNumberTextField.placeholder = @"1234  5678  9012  3456";
        cardNumberTextField.accessibilityLabel = @"Credit Card Number";
        [scrollView addSubview:cardNumberTextField];
        
        monthYearTextField = [[BTPaymentFormTextField alloc] initWithFrame:CGRectMake(105, 5, 60, 30) delegate:self];
        monthYearTextField.placeholder = @"MM/YY";
        monthYearTextField.accessibilityLabel = @"Credit Card Expiration Date";
        [self addSubview:monthYearTextField];
        
        cvvTextField = [[BTPaymentFormTextField alloc] initWithFrame:CGRectMake(169, 5, 45, 30) delegate:self];
        cvvTextField.placeholder = @"CVV";
        cvvTextField.accessibilityLabel = @"Credit Card CVV";
        [self addSubview:cvvTextField];
        
        _requestsZip = YES;
        zipTextField = [[BTPaymentFormTextField alloc] initWithFrame:CGRectMake(215, 5, 80, 30) delegate:self];
        
        [self setupZipKeyboard];
        
        zipTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        zipTextField.minimumFontSize = 10;
        zipTextField.adjustsFontSizeToFitWidth = YES;
        
        zipTextField.placeholder = @"ZIP";
        zipTextField.accessibilityLabel = @"Credit Card Zip";
        [self addSubview:zipTextField];

        [self setSecondaryTextFieldsHidden:YES];
    }
    return self;
}

- (void)setupZipKeyboard {
    BOOL isUKLocale = [[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"];
    if (isUKLocale && self.UKSupportEnabled) {
        zipTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    } else if (self.UKSupportEnabled) {
        // Maybe here - default to a number-first keyboard?
        zipTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    } else {
        zipTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
}

#pragma mark - BTPaymentFormView

- (BOOL)hasValidCardEntry {
    BTPaymentCardType *cardType = [BTPaymentCardUtils cardTypeForNumber:cardNumberTextField.text];

    if (cardType &&
        [BTPaymentCardUtils isValidNumber:cardNumberTextField.text] &&
        monthYearTextField.text.length == 5 &&
        cvvTextField.text.length == [cardType.cvvLength integerValue]) {

        if (!self.requestsZip) {
            // If no zip, the card entry is valid.
            return YES;
        } else if ([self validateZipCode:zipTextField.text]) {
            // If zip is requested, ensure it passes proper regexes.
            return YES;
        }
    }

    return NO;
}

- (BOOL)validateZipCode:(NSString *)zip {
    NSRegularExpression *zipRegex =
    [NSRegularExpression regularExpressionWithPattern:BT_REGEX_ZIP_USA
                                              options:NSRegularExpressionCaseInsensitive
                                                error:nil];
    
    NSRegularExpression *postCodeRegex =
    [NSRegularExpression regularExpressionWithPattern:BT_REGEX_POSTCODE_UK
                                              options:NSRegularExpressionCaseInsensitive
                                                error:nil];
    
    if ([zipRegex numberOfMatchesInString:zip options:0 range:NSMakeRange(0, [zip length])] == 1) {
        return YES;
    }
    
    if (self.UKSupportEnabled && [postCodeRegex numberOfMatchesInString:zip options:0 range:NSMakeRange(0, [zip length])] == 1) {
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)cardEntry {
    NSMutableDictionary *cardEntryDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString *cardNumber      = [self cardNumberEntry];
    NSString *expirationMonth = [self monthExpirationEntry];
    NSString *expirationYear  = [self yearExpirationEntry];
    NSString *cvv             = [self cvvEntry];
    NSString *zipcode         = [self zipEntry];
    
    if (cardNumber) [cardEntryDictionary setObject:cardNumber forKey:@"card_number"];
    if (expirationMonth) [cardEntryDictionary setObject:expirationMonth forKey:@"expiration_month"];
    if (expirationYear) [cardEntryDictionary setObject:expirationYear forKey:@"expiration_year"];
    if (cvv) [cardEntryDictionary setObject:cvv forKey:@"cvv"];
    if (zipcode) [cardEntryDictionary setObject:zipcode forKey:@"zipcode"];

    return cardEntryDictionary;
}

- (NSString *)cardNumberEntry {
    return [BTPaymentCardUtils formatNumberForComputing:cardNumberTextField.text];
}

- (NSString *)monthExpirationEntry {
    return [monthYearTextField.text substringToIndex:2];
}

- (NSString *)yearExpirationEntry {
    return [NSString stringWithFormat:@"20%@", [monthYearTextField.text substringFromIndex:3]];
}

- (NSString *)cvvEntry {
    return cvvTextField.text;
}

- (NSString *)zipEntry {
    return zipTextField.text;
}

#pragma mark - UITextFieldDelegate

// This class is the delegate to every text field in the payment form view. When the user
// edits a text field, this function is triggered. Client side validation and formatting
// is managed here too.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {

    BOOL performTextViewChange = YES;

    if (textField == cardNumberTextField) {
        performTextViewChange = [self cardNumberTextFieldShouldChangeCharactersInRange:range replacementString:string];
    } else if (textField == monthYearTextField) {
        performTextViewChange = [self monthYearTextFieldShouldChangeCharactersInRange:range replacementString:string];
    } else if (textField == cvvTextField) {
        performTextViewChange = [self cvvTextFieldShouldChangeCharactersInRange:range replacementString:string];
    } else if (textField == zipTextField) {
        string = [string uppercaseString];
        performTextViewChange = [self zipTextFieldShouldChangeCharactersInRange:range replacementString:string];
    }

    if (performTextViewChange) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }

    if ([delegate respondsToSelector:@selector(paymentFormView:didModifyCardInformationWithValidity:)]) {
        [delegate paymentFormView:self didModifyCardInformationWithValidity:[self hasValidCardEntry]];
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    BOOL isAmex = [[BTPaymentCardUtils cardTypeForNumber:cardNumberTextField.text] brand] == BTCardBrandAMEX;

    if (textField == cardNumberTextField) {
        [self setSecondaryTextFieldsHidden:YES];
        [scrollView scrollRectToVisible:CGRectMake(0, 0, .5, .5) animated:YES];
    } else if (textField == cvvTextField) {
        // show the CVV image
        [self changeCardImageForCardNumber:cardNumberTextField.text isBackImage:YES
                         animatedFromRight:YES flips:!isAmex];
    } else if (textField == monthYearTextField || textField == zipTextField) {
        // show the card image
        [self changeCardImageForCardNumber:cardNumberTextField.text isBackImage:NO
                         animatedFromRight:YES flips:!isAmex];
    }
}

#pragma mark - Handle form validation for different text fields

- (BOOL)cardNumberTextFieldShouldChangeCharactersInRange:(NSRange)range
                                       replacementString:(NSString *)string {

    [cardNumberTextField resetTextColor];


    NSString *oldCardNumberFormatted = cardNumberTextField.text;
    BOOL endsWithSpaceOnDelete = [oldCardNumberFormatted hasSuffix:@"  "] && !string.length;

    NSString *newCardNumberFormatted = [oldCardNumberFormatted stringByReplacingCharactersInRange:range withString:string];
    if (endsWithSpaceOnDelete) {
        // Remove last character on delete
        newCardNumberFormatted = [newCardNumberFormatted substringToIndex:newCardNumberFormatted.length-2];
    }

    // Remove non-digits
    newCardNumberFormatted = [[newCardNumberFormatted componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];

    // Format for pretty viewing
    newCardNumberFormatted = [BTPaymentCardUtils formatNumberForViewing:newCardNumberFormatted];

    NSString *newCardNumberRaw = [BTPaymentCardUtils formatNumberForComputing:newCardNumberFormatted];
    BTPaymentCardType *newCardType = [BTPaymentCardUtils cardTypeForNumber:newCardNumberRaw];

    // Check for errors in the potential new card number
    if ((!newCardType && newCardNumberRaw.length > 4) ||
        (newCardType && [newCardType.validCardLengths containsObject:[NSNumber numberWithInteger:newCardNumberRaw.length]] &&
         ![BTPaymentCardUtils isValidNumber:newCardNumberRaw] &&
         newCardNumberRaw.length >= [newCardType.maxCardLength integerValue])) {
        // Card number has no type && greater than 4 digits
        // OR card number has type and is greater than or equal to expected card length, but is invalid

        cardNumberTextField.textColor = [UIColor redColor];
        [self shakeView:scrollView completion:nil];
        return NO;
    } else if (newCardType && newCardNumberRaw.length > [newCardType.maxCardLength integerValue]) {
        // Card # is too long
        return NO;
    }

    cardNumberTextField.text = newCardNumberFormatted;
    [self changeCardImageForCardNumber:newCardNumberFormatted
                         isBackImage:NO animatedFromRight:newCardNumberRaw.length flips:YES];
    if ([BTPaymentCardUtils isValidNumber:newCardNumberFormatted]) {
        // If card # is valid, give focus to MM/YY text field
        [scrollView scrollRectToVisible:
         CGRectMake((newCardType.brand == BTCardBrandAMEX ? self.scrollOffsetAmex : self.scrollOffsetGeneric), 0, 100, 30)
                               animated:YES];
        [monthYearTextField becomeFirstResponder];
        [self setSecondaryTextFieldsHidden:NO];
    }
    return NO;
}

- (BOOL)monthYearTextFieldShouldChangeCharactersInRange:(NSRange)range
                                      replacementString:(NSString *)string {
    NSString *text = monthYearTextField.text;
    if (!string.length) {
        // Backspace
        if ([text hasSuffix:@"/"]) {
            if ([text hasPrefix:@"0"]) {
                // Example: delete everything if text is "08/" and user presses delete
                monthYearTextField.text = @"";
            } else {
                // Example: delete "0/" if text is "10/" and user presses delete
                monthYearTextField.text = [text substringToIndex:text.length-2];
            }
            return NO;
        }
        return YES;
    } else if (string.length != 1 || [self stringHasNonDigits:string]) {
        // Is not a valid, single-digit number. (e.g. disable a faulty copy-paste)
        return NO;
    } else if (text.length == 0) {
        // Nothing entered for MM/YY yet
        if ([string integerValue] > 1) {
            monthYearTextField.text = [NSString stringWithFormat:@"0%@/", string];
            return NO;
        }
        return YES;
    } else if (text.length == 1) {
        // User has a "1" in the text field already
        if ([text isEqualToString:@"0"]) {
            monthYearTextField.text = [NSString stringWithFormat:@"%@%@/", text, string];
        } else if ([string integerValue] > 2) {
            [self shakeView:monthYearTextField completion:nil];
        } else {
            monthYearTextField.text = [NSString stringWithFormat:@"%@%@/", text, string];
        }
        return NO;
    } else if ([text hasSuffix:@"/"]) {
        if ([string isEqualToString:@"0"]) {
            // Exp year start with 0
            [self shakeView:monthYearTextField completion:nil];
            return NO;
        }
    } else if (text.length == 4) {
        text = [NSString stringWithFormat:@"%@%@", text, string]; // append to end

        // User entered in a full MM/YY combo
        NSInteger enteredMonth = [[text substringToIndex:2] integerValue];
        NSInteger enteredYear  = [[text substringFromIndex:3] integerValue];
        if ((enteredYear < thisYear) ||
            (enteredYear == thisYear && enteredMonth < thisMonth)) {
            // Exp year is less than this year
            // OR Exp year is this year, but exp month is less than this month
            [self shakeView:monthYearTextField completion:nil];
            return NO;
        }

        // Valid MM/YY, jump to CVV text field
        monthYearTextField.text = text;
        [cvvTextField becomeFirstResponder];
        return NO;
    } else if (text.length >= 5) {
        return NO;
    }
    
    return YES;
}

- (BOOL)cvvTextFieldShouldChangeCharactersInRange:(NSRange)range
                                replacementString:(NSString *)string {
    BTPaymentCardType *cardType = [BTPaymentCardUtils cardTypeForNumber:cardNumberTextField.text];
    NSString *text = cvvTextField.text;
    
    if (!string.length) {
        // backspace
        return YES;
    } else if (string.length != 1 || [self stringHasNonDigits:string] ||
               (text.length >= [cardType.cvvLength integerValue])) {
        // Is not a valid, single-digit number. (e.g. disable a faulty copy-paste)
        // OR CVV length is too long
        return NO;
    } else if (text.length + string.length == [cardType.cvvLength integerValue]) {
        // Valid CVV, jump to zip field.
        text = [text stringByReplacingCharactersInRange:range withString:string];
        cvvTextField.text = text;
        if (_requestsZip) {
            [zipTextField becomeFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)zipTextFieldShouldChangeCharactersInRange:(NSRange)range
                                replacementString:(NSString *)string {
    NSString *text = zipTextField.text;
    
    BOOL hasNonDigits = [self stringHasNonDigits:text];
    NSInteger newTotalLength = text.length + string.length;
    
    if (string.length > 1)
        return NO;
    
    
    if (self.UKSupportEnabled && (hasNonDigits || text.length == 0)) {
        if (newTotalLength > 8)
            return NO;
        
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
        
    } else {
        if (newTotalLength > 5)
            return NO;
        
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890 "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
        
    }
    
    return YES;
}

- (void)setSecondaryTextFieldsHidden:(BOOL)hidden {
    monthYearTextField.hidden =
    cvvTextField.hidden       = hidden;

    // Only show the zip text field if it's requested.
    zipTextField.hidden = (_requestsZip ? hidden : YES);
}

- (BOOL)stringHasNonDigits:(NSString *)string {
    return ([string rangeOfCharacterFromSet:
             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound);
}

#pragma mark - UI tweaks & animations

- (void)changeCardImageForCardNumber:(NSString *)cardNumber isBackImage:(BOOL)isBackImage
                   animatedFromRight:(BOOL)animatedFromRight flips:(BOOL)flips {
    // Get the type of card to display
    BTPaymentCardType *newCardType = [BTPaymentCardUtils cardTypeForNumber:cardNumber];
    NSString *newCardImageName;

    if (isBackImage) {
        // If back image wasn't specified on the card, show the default back image
        newCardImageName = (newCardType.backImageName ? newCardType.backImageName : @"BTCVV");
    } else {
        // If front image wasn't specified on the card, show the default back image
        newCardImageName = (newCardType.frontImageName ? newCardType.frontImageName : @"BTGenericCard");
    }

    if (!flips) {
        // Don't flip image if AMEX and changing to/from CVV
        cardImageView.image = [BTPaymentFormView imageWithName:newCardImageName];
    } else if (![cardImageName isEqualToString:newCardImageName]) {
        // Flip image animation
        [UIView
         transitionWithView:cardImageView duration:0.25f
         options:(animatedFromRight ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft)
         animations:^{
             cardImageView.image = [BTPaymentFormView imageWithName:newCardImageName];
         } completion:nil];
    }
    cardImageName = newCardImageName;
}

- (void)shakeView:(UIView *)viewForAnimation completion:(void (^)(BOOL finished))completion {
    CGFloat t = 3.0;
    CGAffineTransform shakeMoveRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform shakeMoveLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);

    viewForAnimation.transform = shakeMoveLeft;

    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewForAnimation.transform = shakeMoveRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewForAnimation.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    }];
}

- (void)setRequestsZip:(BOOL)requestsZip {
    _requestsZip = requestsZip;

    if (self.zipTextField.isFirstResponder && !requestsZip) {
        [self.zipTextField resignFirstResponder];
    }

    // Only show the zip text field now if CVV is showing and developer chose to show it.
    self.zipTextField.hidden = !(!self.cvvTextField.hidden && requestsZip);

    // Clear the zip text field if it had any text.
    self.zipTextField.text = @"";

    if ([delegate respondsToSelector:@selector(paymentFormView:didModifyCardInformationWithValidity:)]) {
        [delegate paymentFormView:self didModifyCardInformationWithValidity:[self hasValidCardEntry]];
    }
}

#pragma mark - Convenience UI methods

- (void)setOrigin:(CGPoint)origin {
    CGRect newFrame = self.frame;
    newFrame.origin.x = origin.x;
    newFrame.origin.y = origin.y;
    self.frame = newFrame;
}

- (void)setUKSupportEnabled:(BOOL)UKSupportEnabled {
    _UKSupportEnabled = UKSupportEnabled;
    [self setupZipKeyboard];
}

@end
