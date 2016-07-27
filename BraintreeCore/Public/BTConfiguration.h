#import <Foundation/Foundation.h>
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTConfiguration : NSObject

- (instancetype)initWithJSON:(BTJSON *)json NS_DESIGNATED_INITIALIZER;

/// The merchant account's configuration as a `BTJSON` object
@property (nonatomic, readonly, strong) BTJSON *json;

#pragma mark - Undesignated initializers (do not use)

- (nullable instancetype)init __attribute__((unavailable("Please use initWithJSON: instead.")));

/// Returns true if the corresponding beta flag is set
/// Otherwise returns false
///
+ (BOOL)isBetaEnabledPaymentOption:(NSString*)paymentOption DEPRECATED_MSG_ATTRIBUTE("Pay with Venmo is no longer in beta");

/// Set a corresponding beta flag
+ (void)setBetaPaymentOption:(NSString*)paymentOption isEnabled:(BOOL)isEnabled DEPRECATED_MSG_ATTRIBUTE("Pay with Venmo is no longer in beta");

@end

NS_ASSUME_NONNULL_END
