#import "BTPayPalDriver.h"
#import "BTPayPalRequestFactory.h"

@interface BTPayPalDriver ()

- (void)setCheckoutContinuationBlock:(void (^)(BTTokenizedPayPalCheckout *tokenizedCheckout, NSError *error))completionBlock;

@property (nonatomic, strong) BTPayPalRequestFactory *requestFactory;

/// Exposed for testing to provide subclasses of PayPalOneTouchCore to stub class methods
@property (nonatomic, strong) Class payPalClass;

@end
