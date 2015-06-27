#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedPayPalAccount : NSObject <BTTokenized>

@property (nonatomic, copy) NSString *email;

@property (nonatomic, assign) ABRecordRef billingAddress DEPRECATED_MSG_ATTRIBUTE("Please use billingContact");
@property (nonatomic, nullable, strong) CNContact *billingContact;

@end

BT_ASSUME_NONNULL_END
