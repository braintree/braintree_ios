/*
 * Venmo SDK
 *
 ******************************
 * BTPaymentCardType
 ******************************
 *
 * This is a container object for different types of credit cards and their attributes.
 */

typedef NS_ENUM(NSInteger, BTCardBrand) {
    BTCardBrandAMEX,
    BTCardBrandDinersClub,
    BTCardBrandDiscover,
    BTCardBrandMasterCard,
    BTCardBrandVisa,
    BTCardBrandJCB,
    BTCardBrandLaser,
    BTCardBrandMaestro,
    BTCardBrandUnionPay
};

@interface BTPaymentCardType : NSObject

@property (nonatomic, assign) BTCardBrand brand;
@property (nonatomic, copy)   NSString *frontImageName;
@property (nonatomic, copy)   NSString *backImageName;
@property (nonatomic, copy)   NSString *cardRegexPattern;
@property (nonatomic, strong) NSRegularExpression *cardRegex;
@property (nonatomic, strong) NSArray  *validCardLengths;
@property (nonatomic, strong) NSNumber *maxCardLength;
@property (nonatomic, strong) NSNumber *cvvLength;
@property (nonatomic, strong) NSArray  *prettyFormatSpaceIndices;

@end
