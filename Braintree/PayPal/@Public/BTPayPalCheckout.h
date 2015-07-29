@import Foundation;
@import AddressBook;

#import "BTPostalAddress.h"
#import "BTPayPalResource.h"

@interface BTPayPalCheckout : BTPayPalResource

+ (instancetype)checkoutWithAmount:(NSDecimalNumber *)amount;

@property (nonatomic, copy) NSDecimalNumber *amount;
@property (nonatomic, copy) NSString *currencyCode;

@end
