@import Foundation;
@import AddressBook;

@interface BTPayPalCheckout : NSObject

+ (instancetype)checkoutWithAmount:(NSDecimalNumber *)amount;

@property (nonatomic, copy) NSDecimalNumber *amount;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, assign) BOOL enableShippingAddress;
@property (nonatomic, assign) ABRecordRef shippingAddress;

@end
