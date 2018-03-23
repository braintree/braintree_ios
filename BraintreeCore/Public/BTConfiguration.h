#import <Foundation/Foundation.h>
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information specific to a merchant's Braintree integration
 */
@interface BTConfiguration : NSObject

/**
 Used to initialize a `BTConfiguration`
 
 @param json The `BTJSON` to initialize with.
 */
- (instancetype)initWithJSON:(BTJSON *)json NS_DESIGNATED_INITIALIZER;

/**
 The merchant account's configuration as a `BTJSON` object
*/
@property (nonatomic, readonly, strong) BTJSON *json;

#pragma mark - Undesignated initializers (do not use)

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithJSON: instead.")));

/**
 Returns true if the corresponding beta flag is set, otherwise returns false
*/
+ (BOOL)isBetaEnabledPaymentOption:(NSString*)paymentOption DEPRECATED_MSG_ATTRIBUTE("Pay with Venmo is no longer in beta");

/**
 Set a corresponding beta flag
*/
+ (void)setBetaPaymentOption:(NSString*)paymentOption isEnabled:(BOOL)isEnabled DEPRECATED_MSG_ATTRIBUTE("Pay with Venmo is no longer in beta");

@end

NS_ASSUME_NONNULL_END
