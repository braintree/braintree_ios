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

@end

NS_ASSUME_NONNULL_END
