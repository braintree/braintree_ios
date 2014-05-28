#import <Foundation/Foundation.h>
#import "BraintreeDemoClientOperation.h"

@interface BraintreeDemoOperationManager : NSObject

+ (instancetype)manager;

- (BraintreeDemoClientOperation *)clientVersionOperation;
- (BraintreeDemoClientOperation *)reinitializeClientOperation;
- (BraintreeDemoClientOperation *)fetchPaymentMethodsOperation;
- (BraintreeDemoClientOperation *)saveCardOperation;
- (BraintreeDemoClientOperation *)saveInvalidCardOperation;
- (BraintreeDemoClientOperation *)savePayPalPaymentMethodOperation;

@end
