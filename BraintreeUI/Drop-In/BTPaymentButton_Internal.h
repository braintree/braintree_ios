#import "BTPaymentButton.h"

@interface BTPaymentButton ()

/// Collection of payment option strings, e.g. "PayPal", "Coinbase"
- (NSOrderedSet *)filteredEnabledPaymentOptions;

@end
