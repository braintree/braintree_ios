#import <Foundation/Foundation.h>
#import "BTCardPaymentMethod.h"

@interface BTThreeDSecureResponse : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSDictionary *threeDSecureInfo;
@property (nonatomic, strong) BTCardPaymentMethod *paymentMethod;
@property (nonatomic, copy) NSString *errorMessage;

@end
