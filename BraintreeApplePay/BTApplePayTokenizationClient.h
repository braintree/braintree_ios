#import <PassKit/PassKit.h>

#import "BTNullability.h"
#import "BTAPIClient.h"
#import "BTTokenizedApplePayPayment.h"

BT_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BTClientApplePayStatus) {
    BTClientApplePayStatusOff = 0,
    BTClientApplePayStatusMock = 1,
    BTClientApplePayStatusProduction = 2,
};

extern NSString * const BTApplePayErrorDomain;
typedef NS_ENUM(NSInteger, BTApplePayErrorType) {
    BTApplePayErrorTypeUnknown = 0,
    BTApplePayErrorTypeUnsupported,
};

@interface BTApplePayTokenizationClient : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

- (void)tokenizeApplePayPayment:(PKPayment *)payment
                     completion:(void (^)(BTTokenizedApplePayPayment * __BT_NULLABLE tokenizedApplePayPayment, NSError * __BT_NULLABLE error))completionBlock;

@end

BT_ASSUME_NONNULL_END
