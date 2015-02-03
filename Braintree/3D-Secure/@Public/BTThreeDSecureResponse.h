#ifndef BT_THREE_D_SECURE_BETA_WARNING
#define BT_THREE_D_SECURE_BETA_WARNING
#pragma message "⚠️ Braintree's 3D Secure API for iOS is currently in beta and subject to change in the near future"
#endif

@import Foundation;
#import "BTCardPaymentMethod.h"

@interface BTThreeDSecureResponse : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSDictionary *threeDSecureInfo;
@property (nonatomic, strong) BTCardPaymentMethod *paymentMethod;
@property (nonatomic, copy) NSString *errorMessage;

@end
