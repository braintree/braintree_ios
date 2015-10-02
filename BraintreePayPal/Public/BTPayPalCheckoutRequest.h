#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// A PayPal checkout request groups options that control a user-facing PayPal checkout flow.
///
/// A checkout request must specify an anticipated transaction amount.
///
/// @see BTPayPalDriver
@interface BTPayPalCheckoutRequest : NSObject

/// Initialize a checkout request with an amount.
///
/// @param amount An amount greater than or equal to zero.
/// @return A checkout request, or `nil` if the amount is `nil` or less than 0.
- (nullable instancetype)initWithAmount:(NSDecimalNumber *)amount;

@property (nonatomic, readonly, strong) NSDecimalNumber *amount;
@property (nonatomic, nullable, copy) NSString *currencyCode;
@property (nonatomic, nullable, copy) NSString *localeCode;
@property (nonatomic)                    BOOL enableShippingAddress;
@property (nonatomic)                    BOOL addressOverride;
@property (nonatomic, nullable, strong) BTPostalAddress *shippingAddress;

@end

NS_ASSUME_NONNULL_END
