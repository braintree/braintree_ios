#import <Foundation/Foundation.h>
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Contains the bin data associated with a payment method
 */
@interface BTBinData : NSObject

/**
 Create a `BTBinData` object from JSON.
 */
- (instancetype)initWithJSON:(BTJSON *)json;

/**
 Whether the card is a prepaid card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *prepaid;

/**
 Whether the card is a healthcare card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *healthcare;

/**
 Whether the card is a debit card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *debit;

/**
 A value indicating whether the issuing bank's card range is regulated by the Durbin Amendment due to the bank's assets. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *durbinRegulated;

/**
 Whether the card type is a commercial card and is capable of processing Level 2 transactions. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *commercial;

/**
 Whether the card is a payroll card. Possible values: Yes/No/Unknown
 */
@property (nonatomic, nullable, readonly, copy) NSString *payroll;

/**
 The bank that issued the credit card, if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *issuingBank;

/**
 The country that issued the credit card, if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *countryOfIssuance;

/**
 The code for the product type of the card (e.g. `D` (Visa Signature Preferred), `G` (Visa Business)), if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *productId;

@end

NS_ASSUME_NONNULL_END
