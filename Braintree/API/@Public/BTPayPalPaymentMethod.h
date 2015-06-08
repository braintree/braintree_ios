#import "BTPaymentMethod.h"


/// Keys for additionalInformation
extern NSString *const kBTAdditionalInformationKeyAccountAddress;
extern NSString *const kBTAdditionalInformationKeyCity;
extern NSString *const kBTAdditionalInformationKeyCounty;
extern NSString *const kBTAdditionalInformationKeyPostalCode;
extern NSString *const kBTAdditionalInformationKeyState;
extern NSString *const kBTAdditionalInformationKeyStreet1;
extern NSString *const kBTAdditionalInformationKeyStreet2;


/// A payment method returned by the Client API that represents a PayPal account associated with
/// a particular Braintree customer.
///
/// @see BTPaymentMethod
/// @see BTMutablePayPalPaymentMethod
@interface BTPayPalPaymentMethod : BTPaymentMethod <NSMutableCopying>

/// Email address associated with the PayPal Account.
@property (nonatomic, readonly, copy) NSString *email;

/// Additional information provided by custom scopes. Ex: Address information
/// AccountAddress information will be stored in the kBTAdditionalInformationKeyAccountAddress key
/// See additional keys above for more values in the 'accountAddress'
@property (nonatomic, copy) NSDictionary *additionalInformation;

@end
