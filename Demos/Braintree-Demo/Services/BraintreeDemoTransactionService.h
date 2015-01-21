#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BraintreeDemoTransactionServiceEnvironment) {
    BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant = 0,
    BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant = 1,
};

extern NSString *BraintreeDemoTransactionServiceEnvironmentDidChangeNotification;

@interface BraintreeDemoTransactionService : NSObject

+ (instancetype)sharedService;
- (BraintreeDemoTransactionServiceEnvironment)currentEnvironment;

- (BOOL)threeDSecureEnabled;

- (void)fetchMerchantConfigWithCompletion:(void (^)(NSString *merchantId, NSError *error))completionBlock;
- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *clientToken, NSError *error))completionBlock;
- (void)makeTransactionWithPaymentMethodNonce:(NSString *)paymentMethodNonce completion:(void (^)(NSString *transactionId, NSError *error))completionBlock;

@end
