#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@interface BTPayPalCheckout : NSObject

+ (instancetype)checkoutWithAmount:(NSDecimalNumber *)amount;

@property (nonatomic, copy) NSDecimalNumber *amount;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, assign) BOOL enableShippingAddress;
@property (nonatomic, assign) ABRecordRef shippingAddress DEPRECATED_MSG_ATTRIBUTE("Please use shippingContact");

@end
