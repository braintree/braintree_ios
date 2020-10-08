#import <BraintreeCore/BraintreeCore.h>

/**
 Contains information about a Venmo Account payment method
 */
@interface BTVenmoAccountNonce : BTPaymentMethodNonce

/**
 The username associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *username;

@end
