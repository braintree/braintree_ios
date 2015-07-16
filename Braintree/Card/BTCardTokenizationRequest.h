#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

/// The card tokenization request represents raw credit or debit card data provided by the customer.
/// Its main purpose is to serve as the input for tokenization.
@interface BTCardTokenizationRequest : NSObject

- (instancetype)init;

/// A convenience initializer for creating a card tokenization request.
- (instancetype)initWithNumber:(BT_NULLABLE NSString *)number expirationDate:(BT_NULLABLE NSString *)expirationDate cvv:(BT_NULLABLE NSString *)cvv;

- (instancetype)initWithParameters:(NSDictionary *)parameters NS_DESIGNATED_INITIALIZER;

@property (nonatomic, BT_NULLABLE, copy) NSString *number;
@property (nonatomic, BT_NULLABLE, copy) NSString *expirationDate;
@property (nonatomic, BT_NULLABLE, copy) NSString *cvv;
@property (nonatomic, BT_NULLABLE, copy) NSString *postalCode;

@property (nonatomic, assign) BOOL shouldValidate;

@end

BT_ASSUME_NONNULL_END
