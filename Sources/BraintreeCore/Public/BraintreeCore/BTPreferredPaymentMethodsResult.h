#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 :nodoc:
 Contains information about which payment methods are preferred on the device.
 
 This class is currently in beta and may change in future releases.
*/
@interface BTPreferredPaymentMethodsResult : NSObject

/**
 :nodoc:
 True if PayPal is a preferred payment method. False otherwise.
*/
@property (nonatomic, readonly, assign) BOOL isPayPalPreferred;

/**
 :nodoc:
 True if Venmo app is installed on the customer's device. False otherwise.
*/
@property (nonatomic, readonly, assign) BOOL isVenmoPreferred;

@end

NS_ASSUME_NONNULL_END
