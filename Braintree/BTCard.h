#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

/// The card model represents raw credit or debit card data provided by the customer.
///
/// Its main purpose is to serve as the input for tokenization.
@interface BTCard : NSObject

- (instancetype)initWithNumber:(nullable NSString *)number expirationDate:(nullable NSString *)expirationDate cvv:(nullable NSString *)cvv;

+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationDate:(nullable NSString *)expirationDate cvv:(nullable NSString *)cvv;
+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationDate:(nullable NSString *)expirationDate;
+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationMonth:(nullable NSString *)expirationMonth expirationYear:(NSString *)expirationYear cvv:(nullable NSString *)cvv;
+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationMonth:(nullable NSString *)expirationMonth expirationYear:(NSString *)expirationYear;

/// @name Parameters

@property (nonatomic, nullable, copy) NSString *number;
@property (nonatomic, nullable, copy) NSString *cvv;
@property (nonatomic, nullable, copy) NSString *postalCode;
@property (nonatomic, nullable, copy) NSDictionary<NSString *,NSString *> *additionalParameters;

@end

BT_ASSUME_NONNULL_END
