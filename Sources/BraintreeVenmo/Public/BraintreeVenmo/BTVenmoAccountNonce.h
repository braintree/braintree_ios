#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 Contains information about a Venmo Account payment method
 */
@interface BTVenmoAccountNonce : BTPaymentMethodNonce

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

/**
 TThe primary billing address associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) BTPostalAddress *billingAddress;

/**
 The primary shipping address associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) BTPostalAddress *shippingAddress;

@end
