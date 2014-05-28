#import "BTUICardType.h"
#import "BTUIUtil.h"

#define kDefaultFormatSpaceIndices @[@4, @8, @12, @16]
#define kDefaultCvvLength          3
#define kDefaultValidNumberLengths [NSIndexSet indexSetWithIndex:16]
#define kInvalidCvvCharacterSet    [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]


@implementation BTUICardType

#pragma mark - Private initializers

- (instancetype)initWithBrand:(NSString *)brand
                      pattern:(NSString *)pattern
{
    return [self initWithBrand:brand
                       pattern:pattern
            validNumberLengths:kDefaultValidNumberLengths
                validCvvLength:kDefaultCvvLength
                  formatSpaces:kDefaultFormatSpaceIndices];
}

- (instancetype)initWithBrand:(NSString *)brand
                      pattern:(NSString *)pattern
           validNumberLengths:(NSIndexSet *)validLengths
               validCvvLength:(NSUInteger)cvvLength
                 formatSpaces:(NSArray *)formatSpaces
{
    self = [super init];
    if (self != nil) {
        _brand = brand;
        NSError *error;
        _validNumberRegex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        if (error != nil) {
            NSLog(@"Braintree-Payments-UI: %@", error);
        }
        _validNumberLengths = validLengths;
        _validCvvLength = cvvLength;

        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]];
        _formatSpaces = [formatSpaces sortedArrayUsingDescriptors:sortDescriptors] ?: kDefaultFormatSpaceIndices;
        _maxNumberLength = [validLengths lastIndex];
    }
    return self;
}

#pragma mark - Finders

+ (instancetype)cardTypeForBrand:(NSString *)rename {
    return [[self class] cardsByBrand][rename];
}

+ (instancetype)cardTypeForNumber:(NSString *)number {
    number = [BTUIUtil stripNonDigits:number];
    for (BTUICardType *cardType in [[self class] allCards]) {
        if ([cardType.validNumberRegex numberOfMatchesInString:number options:0 range:NSMakeRange(0, number.length)] == 1) {
            return cardType;
        }
    }
    return nil;
}

#pragma mark - Instance methods

- (BOOL)validCvv:(NSString *)cvv {
    if (cvv.length != self.validCvvLength) {
        return NO;
    }
    return ([cvv rangeOfCharacterFromSet:kInvalidCvvCharacterSet].location == NSNotFound);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"BTUICardType %@", self.brand];
}

#pragma mark - Immutable singletons

+ (NSUInteger)maxNumberLength {
    static dispatch_once_t p = 0;
    static NSUInteger _maxNumberLength = 0;
    dispatch_once(&p, ^{
        for (BTUICardType *t in [self allCards]) {
            _maxNumberLength = MAX(_maxNumberLength, t.maxNumberLength);
        }
    });
    return _maxNumberLength;
}

+ (NSArray *)allCards
{
    static dispatch_once_t p = 0;
    static NSArray *_allCards = nil;

    dispatch_once(&p, ^{

        BTUICardType *visa = [[BTUICardType alloc] initWithBrand:BTUICardBrandVisa pattern:@"^4"];
        BTUICardType *mastercard = [[BTUICardType alloc] initWithBrand:BTUICardBrandMasterCard pattern:@"^5[1-5]"];
        BTUICardType *discover = [[BTUICardType alloc] initWithBrand:BTUICardBrandDiscover pattern:@"^(6011|65|64[4-9]|622)"];
        BTUICardType *jcb = [[BTUICardType alloc] initWithBrand:BTUICardBrandJCB pattern:@"^35"];

        BTUICardType *amex = [[BTUICardType alloc] initWithBrand:BTUICardBrandAMEX
                                                         pattern:@"^3[47]"
                                              validNumberLengths:[NSIndexSet indexSetWithIndex:15]
                                                  validCvvLength:4
                                                    formatSpaces:@[@4, @10]];

        BTUICardType *dinersClub = [[BTUICardType alloc] initWithBrand:BTUICardBrandDinersClub
                                                               pattern:@"^(36|38|30[0-5])"
                                                    validNumberLengths:[NSIndexSet indexSetWithIndex:14]
                                                        validCvvLength:3
                                                          formatSpaces:nil];

        BTUICardType *maestro = [[BTUICardType alloc] initWithBrand:BTUICardBrandMaestro
                                                            pattern:@"^(5018|5020|5038|6304|6759|676[1-3])"
                                                 validNumberLengths:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(12, 8)]
                                                     validCvvLength:3
                                                       formatSpaces:nil];

        BTUICardType *unionPay = [[BTUICardType alloc] initWithBrand:BTUICardBrandUnionPay
                                                             pattern:@"^62"
                                                  validNumberLengths:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(16, 4)]
                                                      validCvvLength:3
                                                        formatSpaces:nil];

        _allCards = @[visa, mastercard, discover, amex, dinersClub, jcb, mastercard, maestro, unionPay];
    });

    // returns the same object each time
    return _allCards;
}

+ (NSDictionary *)cardsByBrand {

    static dispatch_once_t p = 0;
    static NSDictionary *_cardsByBrand = nil;

    dispatch_once(&p, ^{
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        for (BTUICardType *cardType in [self allCards]) {
            d[cardType.brand] = cardType;
        }
        _cardsByBrand = d;
    });
    return _cardsByBrand;
}

#pragma mark - Formatting

- (NSAttributedString *)formatNumber:(NSString *)input kerning:(CGFloat)kerning{

    input = [BTUIUtil stripNonDigits:input];

    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:input];

    if (input.length > self.maxNumberLength) {
        return result;
    }

    for (NSNumber *indexNumber in self.formatSpaces) {
        NSUInteger index = [indexNumber unsignedIntegerValue];
        if (index >= result.length) {
            break;
        }
        [result setAttributes:@{NSKernAttributeName: @(kerning)} range:NSMakeRange(index-1, 1)];
    }
    return result;
}

- (NSAttributedString *)formatNumber:(NSString *)input {
    return [self formatNumber:input kerning:8.0f];
}

#pragma mark - Validation

- (BOOL)validNumber:(NSString *)number {
    return ([self completeNumber:number] && [BTUIUtil luhnValid:number]);
}

- (BOOL)completeNumber:(NSString *)number {
    return [self.validNumberLengths containsIndex:number.length];
}



@end
