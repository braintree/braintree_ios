#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTCheckout : NSObject

@property (nonatomic, strong) id<BTTokenized> tokenizedPaymentMethod;

@property (nonatomic, strong) NSDecimalNumber *grandTotal;

@property (nonatomic, assign, readonly) ABRecordRef shippingAddress DEPRECATED_MSG_ATTRIBUTE("Please use shippingContact");
@property (nonatomic, assign, readonly) ABRecordRef billingAddress DEPRECATED_MSG_ATTRIBUTE("Please use billingContact");

@property (nullable, nonatomic, readonly) CNContact *shippingContact;
@property (nullable, nonatomic, readonly) CNContact *billingContacAddresst;

@end

BT_ASSUME_NONNULL_END
