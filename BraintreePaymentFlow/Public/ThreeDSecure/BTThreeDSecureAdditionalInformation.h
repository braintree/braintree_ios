#import <Foundation/Foundation.h>
#import "BTThreeDSecurePostalAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureAdditionalInformation : NSObject

/**
 Optional. First name associated with the address
 */
@property (nonatomic, nullable, copy) NSString *billingGivenName;

/**
 Optional. Last name associated with the address
 */
@property (nonatomic, nullable, copy) NSString *billingSurname;

/**
 Optional. The phone number associated with the address
 @note Only numbers. Remove dashes, parentheses and other characters
 */
@property (nonatomic, nullable, copy) NSString *billingPhoneNumber;

/**
 Optional. The email used for verification
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 Optional. The billing address used for verification
 @see BTThreeDSecurePostalAddress
 */
@property (nonatomic, nullable, copy) BTThreeDSecurePostalAddress *billingAddress;

/**
 Optional. The 2-digit string indicating the shipping method chosen for the transaction
 Possible Values:
 01 Same Day
 02 Overnight / Expedited
 03 Priority (2-3 Days)
 04 Ground
 05 Electronic Delivery
 06 Ship to Store
 */
@property (nonatomic, nullable, copy) NSString *shippingMethod;

@end

NS_ASSUME_NONNULL_END
