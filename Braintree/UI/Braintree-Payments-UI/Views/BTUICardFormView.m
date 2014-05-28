#import "BTUICardFormView.h"
#import "BTUICardNumberField.h"
#import "BTUICardExpiryField.h"
#import "BTUICardCvvField.h"
#import "BTUICardPostalCodeField.h"
#import "BTUI.h"

@interface BTUICardFormView ()<BTUICardNumberFieldDelegate,BTUICardExpiryFieldDelegate,BTUICardCvvFieldDelegate,BTUICardPostalCodeFieldDelegate>

@property (nonatomic, strong) BTUICardNumberField *numberField;
@property (nonatomic, strong) BTUICardExpiryField *expiryField;
@property (nonatomic, strong) BTUICardCvvField *cvvField;
@property (nonatomic, strong) BTUICardPostalCodeField *postalCodeField;

@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *dynamicConstraints;

@end

@implementation BTUICardFormView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, CGRectGetMaxY([[self.fields lastObject] frame]));
}

#pragma mark - Getters/setters

- (void)setAlphaNumericPostalCode:(BOOL)alphaNumericPostalCode {
    _alphaNumericPostalCode = alphaNumericPostalCode;
    self.postalCodeField.nonDigitsSupported = alphaNumericPostalCode;
}

- (void)setOptionalFields:(BTUICardFormOptionalFields)optionalFields {
    _optionalFields = optionalFields;
    NSMutableArray *fields = [NSMutableArray arrayWithObjects:self.numberField, self.expiryField, nil];

    self.cvvField.hidden = self.postalCodeField.hidden = YES;
    if (optionalFields & BTUICardFormOptionalFieldsCvv) {
        [fields addObject:self.cvvField];
        self.cvvField.hidden = NO;
    }
    if (optionalFields & BTUICardFormOptionalFieldsPostalCode) {
        [fields addObject:self.postalCodeField];
        self.postalCodeField.hidden = NO;
    }
    self.fields = fields;
    [self updateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self invalidateIntrinsicContentSize];
}

- (void)setup {
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];

    self.dynamicConstraints = @[];

    _numberField = [[BTUICardNumberField alloc] init];
    self.numberField.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberField.delegate = self;
    self.numberField.bottomBorder = YES;
    [self addSubview:self.numberField];

    _expiryField = [[BTUICardExpiryField alloc] init];
    self.expiryField.translatesAutoresizingMaskIntoConstraints = NO;
    self.expiryField.delegate = self;
    self.expiryField.bottomBorder = YES;
    [self addSubview:self.expiryField];

    _cvvField = [[BTUICardCvvField alloc] init];
    self.cvvField.translatesAutoresizingMaskIntoConstraints = NO;
    self.cvvField.delegate = self;
    self.cvvField.bottomBorder = YES;
    [self addSubview:self.cvvField];

    _postalCodeField = [[BTUICardPostalCodeField alloc] init];
    self.postalCodeField.translatesAutoresizingMaskIntoConstraints = NO;
    self.postalCodeField.delegate = self;
    self.postalCodeField.nonDigitsSupported = NO;
    [self addSubview:self.postalCodeField];

    self.optionalFields = BTUICardFormOptionalFieldsAll;


    for (UIView *v in self.fields) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:@{} views:@{@"v": v}]];
    }


    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]"
                                                                 options:0
                                                                 metrics:0
                                                                   views:@{@"v": self.numberField}]];

    // Layout now (early) so that we can calculate the correct intrinsic content size
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self invalidateIntrinsicContentSize];
}

- (void)updateConstraints {
    [self removeConstraints:self.dynamicConstraints];

    NSMutableArray *newContraints = [NSMutableArray array];
    UIView *viewAbove = self.numberField;
    for (UIView *view in self.fields){
        if(view != self.numberField){
            [newContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v]-(-1)-[v2]"
                                                                         options:0
                                                                         metrics:0
                                                                           views:@{@"v": viewAbove, @"v2": view }]];
            viewAbove = view;
        }
        
    }
    self.dynamicConstraints = newContraints;
    [self addConstraints:self.dynamicConstraints];

    [super updateConstraints];

}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.theme.borderColor setFill];

    // Top
    CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x, 0, rect.size.width, 0.5f), NULL);
    CGContextAddPath(context, path);

    // Bottom
    path = CGPathCreateWithRect(CGRectMake(rect.origin.x, CGRectGetMaxY(rect) - 0.5f, rect.size.width, 0.5f), NULL);
    CGContextAddPath(context, path);

    CGContextDrawPath(context, kCGPathFill);
    CGPathRelease(path);
}

#pragma mark - Validity

- (BOOL)valid {
    for (BTUIFormField *f in self.fields) {
        if (!f.valid) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Field delegate implementations

- (void)cardNumberFieldDidChange:(BTUICardNumberField *)field {
   _number = field.number;
    self.cvvField.cardType = field.cardType;
    [self advanceToNextInvalidFieldFrom:field];
    [self.delegate cardFormViewDidChange:self];
}

- (void)cardExpiryDidChange:(BTUICardExpiryField *)field {
    _expirationYear = field.expirationYear;
    _expirationMonth = field.expirationMonth;
    [self advanceToNextInvalidFieldFrom:field];
    [self.delegate cardFormViewDidChange:self];
}

- (void)cardCvvDidChange:(BTUICardCvvField *)field {
    _cvv = field.cvv;
    [self advanceToNextInvalidFieldFrom:field];
    [self.delegate cardFormViewDidChange:self];
}

- (void)cardPostalCodeDidChange:(BTUICardPostalCodeField *)field {
    _postalCode = field.postalCode;
    [self advanceToNextInvalidFieldFrom:field];
    [self.delegate cardFormViewDidChange:self];
}

#pragma mark - Auto-advancing

- (void)advanceToNextInvalidFieldFrom:(BTUIFormField *)field {
    if (field.entryComplete) {
        NSUInteger fieldIndex = [self.fields indexOfObject:field];
        NSUInteger startIndex = (fieldIndex + 1) % self.fields.count;

        for (NSUInteger i = startIndex ; i != fieldIndex; i = (i + 1) % self.fields.count) {
            BTUIFormField *ithField = self.fields[i];
            if (!ithField.valid) {
                [ithField becomeFirstResponder];
                break;
            }
        }
    }
}

@end
