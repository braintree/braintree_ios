#import <Foundation/Foundation.h>

@interface BraintreeDemoTransactionService : NSObject

+ (instancetype)sharedService;
- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *clientToken, NSError *error))completionBlock;
- (void)makeTransactionWithPaymentMethodNonce:(NSString *)paymentMethodNonce completion:(void (^)(NSString *transactionId, NSError *error))completionBlock;

@end
