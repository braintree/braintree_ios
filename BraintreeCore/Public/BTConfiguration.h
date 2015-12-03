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
+ (BOOL)isBetaEnabledPaymentOption:(NSString*)paymentOption;

/// Set a corresponding beta flag
+ (void)setBetaPaymentOption:(NSString*)paymentOption isEnabled:(BOOL)isEnabled;

@end

NS_ASSUME_NONNULL_END
