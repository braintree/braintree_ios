#import <Foundation/Foundation.h>

static NSString * const BTUICardBrandAMEX = @"American Express";
static NSString * const BTUICardBrandDinersClub = @"Diners Club";
static NSString * const BTUICardBrandDiscover = @"Discover";
static NSString * const BTUICardBrandMasterCard = @"MasterCard";
static NSString * const BTUICardBrandVisa = @"Visa";
static NSString * const BTUICardBrandJCB = @"JCB";
static NSString * const BTUICardBrandMaestro = @"Maestro";
static NSString * const BTUICardBrandUnionPay = @"UnionPay";

/// Immutable card type
@interface BTUICardType : NSObject

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

/// Check if the CVV is valid for a `BTCardType`
- (BOOL)validCvv:(NSString *)cvv;

/// Format a number based on type
/// Does NOT validate
- (NSAttributedString *)formatNumber:(NSString *)input;
- (NSAttributedString *)formatNumber:(NSString *)input kerning:(CGFloat)kerning;

+ (NSUInteger)maxNumberLength;

@property (nonatomic, copy, readonly) NSString *brand;
@property (nonatomic, strong, readonly) NSArray *validNumberPrefixes;
@property (nonatomic, strong, readonly) NSIndexSet  *validNumberLengths;
@property (nonatomic, assign, readonly) NSUInteger validCvvLength;

@property (nonatomic, strong, readonly) NSArray  *formatSpaces;
@property (nonatomic, assign, readonly) NSUInteger maxNumberLength;

@end
