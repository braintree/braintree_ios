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
 The email associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *email;

/**
 The external ID associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *externalId;

/**
 The first name associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *firstName;

/**
 The last name associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *lastName;

/**
 The phone number associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *phoneNumber;

/**
 The username associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *username;

@end
