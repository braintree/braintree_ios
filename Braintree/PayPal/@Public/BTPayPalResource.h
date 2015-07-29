@import Foundation;
@import AddressBook;

#import "BTPostalAddress.h"

@interface BTPayPalResource : NSObject

@property (nonatomic, copy) NSString *localeCode;
@property (nonatomic, assign) BOOL enableShippingAddress;
@property (nonatomic, assign) BOOL addressOverride;
@property (nonatomic, strong) BTPostalAddress *shippingAddress;

@end
