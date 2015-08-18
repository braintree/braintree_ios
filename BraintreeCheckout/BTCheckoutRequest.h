#import <Foundation/Foundation.h>
#import <BraintreeCore/BTPaymentOption.h>

BT_ASSUME_NONNULL_BEGIN

@interface BTCheckoutRequest : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, copy) NSString *clientKey;

@property (nonatomic, nullable, strong) NSDecimalNumber *amount;

@property (nonatomic, nullable, copy) NSString *merchantAccount;

@property (nonatomic, strong) NSArray<BTPaymentOption *> *paymentOptions;

@property (nonatomic, assign) BOOL requireShippingAddress;

@property (nonatomic, assign) BOOL disableBraintreeVault;

@property (nonatomic, nullable, copy) NSString *submitButtonText;

@property (nonatomic, nullable, copy) NSString *summaryTitle;

@property (nonatomic, nullable, copy) NSString *summaryDescription;

@end

BT_ASSUME_NONNULL_END
