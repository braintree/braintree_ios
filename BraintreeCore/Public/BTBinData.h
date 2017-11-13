#import <Foundation/Foundation.h>
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTBinData : NSObject

/**
 @brief Create a `BTBinData` object from JSON.
 */
- (instancetype)initWithJSON:(BTJSON *)json;

/**
 @brief Whether the card is a prepaid card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *prepaid;

/**
 @brief Whether the card is a healthcare card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *healthcare;

/**
 @brief Whether the card is a debit card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *debit;

/**
 @brief A value indicating whether the issuing bank's card range is regulated by the Durbin Amendment due to the bank's assets. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *durbinRegulated;

/**
 @brief Whether the card type is a commercial card and is capable of processing Level 2 transactions. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *commercial;

/**
 @brief Whether the card is a payroll card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *payroll;

/**
 @brief The bank that issued the credit card, if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *issuingBank;

/**
 @brief The country that issued the credit card, if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *countryOfIssuance;

/**
 @brief The code for the product type of the card (e.g. `D` (Visa Signature Preferred), `G` (Visa Business)), if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *productId;

@end

NS_ASSUME_NONNULL_END
