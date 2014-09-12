#import <Foundation/Foundation.h>

@class PKPayment;

@interface BTClientApplePayRequest : NSObject

- (instancetype)initWithApplePayPayment:(PKPayment *)payment;

@property (nonatomic, strong, readonly) PKPayment *payment;

@end
