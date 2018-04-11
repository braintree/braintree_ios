#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 Contains information about a Venmo Account payment method
 */
@interface BTVenmoAccountNonce : BTPaymentMethodNonce

/**
 The username associated with the Venmo account
*/
@property (nonatomic, nullable, readonly, copy) NSString *username;

@end
