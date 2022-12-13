#import <Foundation/Foundation.h>

/**
 Contains information about a Venmo Account payment method
 */
@interface BTVenmoAccountNonce : NSObject

/**
 The payment method nonce.
 */
@property (nonatomic, readonly, strong) NSString * _Nonnull nonce;

/**
 The string identifying the type of the payment method.
 */
@property (nonatomic, readonly, strong) NSString * _Nullable type;

/**
 The boolean indicating whether this is a default payment method.
 */
@property (nonatomic, readwrite, assign) BOOL isDefault;

/**
 :nodoc:
 The email associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *email;

/**
 :nodoc:
 The external ID associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *externalId;

/**
 :nodoc:
 The first name associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *firstName;

/**
 :nodoc:
 The last name associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *lastName;

/**
 :nodoc:
 The phone number associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *phoneNumber;

/**
 The username associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *username;

@end
