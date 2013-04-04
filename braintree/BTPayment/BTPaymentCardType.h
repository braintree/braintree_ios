/*
 * Venmo SDK
 *
 ******************************
 * BTPaymentCardType
 ******************************
 *
 * This is a container object for different types of credit cards and their attributes.
 */

typedef enum {
    BTCardBrandAMEX,
    BTCardBrandDinersClub,
    BTCardBrandDiscover,
    BTCardBrandMasterCard,
    BTCardBrandVisa,
    BTCardBrandJCB,
    BTCardBrandLaser,
    BTCardBrandMaestro,
    BTCardBrandUnionPay
} BTCardBrand;

@interface BTPaymentCardType : NSObject

@property (nonatomic)         BTCardBrand brand;
@property (copy, nonatomic)   NSString *frontImageName;
@property (copy, nonatomic)   NSString *backImageName;
@property (copy, nonatomic)   NSString *cardRegexPattern;
@property (strong, nonatomic) NSRegularExpression *cardRegex;
@property (strong, nonatomic) NSArray  *validCardLengths;
@property (strong, nonatomic) NSNumber *maxCardLength;
@property (strong, nonatomic) NSNumber *cvvLength;
@property (strong, nonatomic) NSArray  *prettyFormatSpaceIndices;

@end
