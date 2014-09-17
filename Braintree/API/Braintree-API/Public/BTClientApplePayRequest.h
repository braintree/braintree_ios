#import <Foundation/Foundation.h>

@class PKPayment;

/// A builder for preparing save Apple Pay Token client API requests.
///
/// @see -[BTClient saveApplePayPayment:]
@interface BTClientApplePayRequest : NSObject

/// Initializes an Apple Pay Request with a PKPayment.
///
/// @param payment The PKPayment containing the encrypted payment data.
///
/// @return An initialized save Apple Pay request.
- (instancetype)initWithApplePayPayment:(PKPayment *)payment;

/// Returns the PKPayment for which this object was initialized.
@property (nonatomic, strong, readonly) PKPayment *payment;

@end
