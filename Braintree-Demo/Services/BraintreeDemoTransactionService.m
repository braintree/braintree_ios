#import "BraintreeDemoTransactionService.h"
#import <AFNetworking/AFNetworking.h>

NSString *BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey = @"BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey";

@interface BraintreeDemoTransactionService ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *sessionManager;
@end

@implementation BraintreeDemoTransactionService

+ (instancetype)sharedService {
    static BraintreeDemoTransactionService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setEnvironment:[[self class] mostRecentlyUsedEnvironment]];
    }
    return self;
}

+ (BraintreeDemoTransactionServiceEnvironment)mostRecentlyUsedEnvironment {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey];
}

- (void)setEnvironment:(BraintreeDemoTransactionServiceEnvironment)environment {
    switch (environment) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://braintree-sample-merchant.herokuapp.com"]];
            break;
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://executive-sample-merchant.herokuapp.com"]];
            break;
        case BraintreeDemoTransactionServiceEnvironmentQASampleMerchant:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://braintree-qa-merchant.herokuapp.com"]];
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:environment forKey:BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fetchMerchantConfigWithCompletion:(void (^)(NSString *merchantId, NSError *error))completionBlock {
    [self.sessionManager GET:@"/config/current"
              parameters:nil
                 success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
                     if (completionBlock) {
                         completionBlock(responseObject[@"merchant_id"], nil);
                     }
                 } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                     completionBlock(nil, error);
                 }];
}

- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *, NSError *))completionBlock {
    NSString *customerId = [[NSUUID UUID] UUIDString];
    [self.sessionManager GET:@"/client_token"
                  parameters:@{@"customer_id": customerId}
                     success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
                         completionBlock(responseObject[@"client_token"], nil);
                     }
                     failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                         completionBlock(nil, error);
                     }];
}

- (void)makeTransactionWithPaymentMethodNonce:(NSString *)paymentMethodNonce completion:(void (^)(NSString *transactionId, NSError *error))completionBlock {
    [self.sessionManager POST:@"/nonce/transaction"
                   parameters:@{@"payment_method_nonce": paymentMethodNonce}
                      success:^(__unused AFHTTPRequestOperation *operation, __unused id responseObject) {
                          completionBlock(responseObject[@"message"], nil);
                      }
                      failure:^(__unused AFHTTPRequestOperation *operation, __unused NSError *error) {
                          completionBlock(nil, error);
                      }];
}

@end
