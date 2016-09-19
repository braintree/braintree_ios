#import <UIKit/UIKit.h>

#import "BTUIKLocalizedString.h"

/// Immutable card type
@interface BTUIKCardType : NSObject

/// Obtain the `BTCardType` for the given brand, or nil if none is found
+ (instancetype)cardTypeForBrand:(NSString *)brand;

/// Obtain the `BTCardType` for the given number, or nil if none is found
+ (instancetype)cardTypeForNumber:(NSString *)number;

/// Return all possible card types for a number
+ (NSArray *)possibleCardTypesForNumber:(NSString *)number;

/// Check if a number is valid
- (BOOL)validNumber:(NSString *)number;

/// Check if a number is complete
- (BOOL)completeNumber:(NSString *)number;

/// Check is a number is valid and necessarily complete
/// (i.e. it can't get any longer)
- (BOOL)validAndNecessarilyCompleteNumber:(NSString *)number;

/// Check if the CVV is valid for a `BTCardType`
- (BOOL)validCvv:(NSString *)cvv;

/// Format a number based on type
/// Does NOT validate
- (NSAttributedString *)formatNumber:(NSString *)input;
- (NSAttributedString *)formatNumber:(NSString *)input kerning:(CGFloat)kerning;

/// Max number of characters allowed for a card number
+ (NSUInteger)maxNumberLength;

/// The card's brand
@property (nonatomic, copy, readonly) NSString *brand;

/// An array of valid number prefixes
@property (nonatomic, strong, readonly) NSArray *validNumberPrefixes;

/// The valid card number lengths
@property (nonatomic, strong, readonly) NSIndexSet  *validNumberLengths;

/// The valid CVV length
@property (nonatomic, assign, readonly) NSUInteger validCvvLength;

/// An array representing the spacing in the card number
/// Ex: @[@4, @8, @12, @16]
@property (nonatomic, strong, readonly) NSArray  *formatSpaces;

/// Max length of the card number
@property (nonatomic, assign, readonly) NSUInteger maxNumberLength;

/// Brand-specific name for card security code
@property (nonatomic, assign, readonly) NSString *securityCodeName;

@end
