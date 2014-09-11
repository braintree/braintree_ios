#import <Foundation/Foundation.h>
#import "BTPaymentApplePayConfiguration.h"
#import "BTClient.h"

@interface BTClient (BTPaymentApplePay)

@property (nonatomic, strong, readonly) BTPaymentApplePayConfiguration *btPayment_applePayConfiguration;

@end
