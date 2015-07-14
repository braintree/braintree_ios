@import Foundation;
@import AddressBook;
#import "BTPostalAddress.h"

@interface BTPayPalCheckout : NSObject

+ (instancetype)checkoutWithAmount:(NSDecimalNumber *)amount;

@property (nonatomic, copy) NSDecimalNumber *amount;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, copy) NSString *localeCode;
@property (nonatomic, assign) BOOL enableShippingAddress;
@property (nonatomic, assign) BOOL addressOverride;
@property (nonatomic, strong) BTPostalAddress *shippingAddress;

@end
