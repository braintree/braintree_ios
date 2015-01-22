#import "BraintreeDemoMerchantAPI.h"
#import <AFNetworking/AFNetworking.h>

#import "BraintreeDemoSettings.h"

NSString *BraintreeDemoMerchantAPIEnvironmentDidChangeNotification = @"BraintreeDemoTransactionServiceEnvironmentDidChangeNotification";

@interface BraintreeDemoMerchantAPI ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *sessionManager;
@property (nonatomic, assign) BraintreeDemoTransactionServiceEnvironment currentEnvironment;
@property (nonatomic, assign) BraintreeDemoTransactionServiceThreeDSecureRequiredStatus threeDSecureRequiredStatus;
@end

@implementation BraintreeDemoMerchantAPI

+ (instancetype)sharedService {
    static BraintreeDemoMerchantAPI *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.currentEnvironment = -1;
        self.threeDSecureRequiredStatus = -1;
        [self setupSessionManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSessionManager) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)setupSessionManager {
    if (self.currentEnvironment != [BraintreeDemoSettings currentEnvironment] || self.threeDSecureRequiredStatus != [BraintreeDemoSettings threeDSecureRequiredStatus]) {
        self.currentEnvironment = [BraintreeDemoSettings currentEnvironment];
        self.threeDSecureRequiredStatus = [BraintreeDemoSettings threeDSecureRequiredStatus];
        switch (self.currentEnvironment) {
            case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
                self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://braintree-sample-merchant.herokuapp.com"]];
                break;
            case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
                self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://executive-sample-merchant.herokuapp.com"]];
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:BraintreeDemoMerchantAPIEnvironmentDidChangeNotification object:self];
    }
}

- (NSString *)merchantAccountId {
    if ([BraintreeDemoSettings currentEnvironment] == BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant && [BraintreeDemoSettings threeDSecureEnabled]) {
        return @"test_AIB";
    }

    return nil;
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
    NSMutableDictionary *parameters = [@{ @"customer_id": customerId } mutableCopy];

    if (self.merchantAccountId) {
        parameters[@"merchant_account_id"] = self.merchantAccountId;
    }

    [self.sessionManager GET:@"/client_token"
                  parameters:parameters
                     success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
                         completionBlock(responseObject[@"client_token"], nil);
                     }
                     failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                         completionBlock(nil, error);
                     }];
}

- (void)makeTransactionWithPaymentMethodNonce:(NSString *)paymentMethodNonce completion:(void (^)(NSString *transactionId, NSError *error))completionBlock {
    NSLog(@"Creating a transaction with nonce: %@", paymentMethodNonce);
    NSDictionary *parameters;

    switch ([BraintreeDemoSettings threeDSecureRequiredStatus]) {
        case BraintreeDemoTransactionServiceThreeDSecureRequiredStatusDefault:
            parameters = @{ @"payment_method_nonce": paymentMethodNonce };
            break;
        case BraintreeDemoTransactionServiceThreeDSecureRequiredStatusRequired:
            parameters = @{ @"payment_method_nonce": paymentMethodNonce, @"three_d_secure_required": @YES, };
            break;
        case BraintreeDemoTransactionServiceThreeDSecureRequiredStatusNotRequired:
            parameters = @{ @"payment_method_nonce": paymentMethodNonce, @"three_d_secure_required": @NO, };
            break;
    }

    [self.sessionManager POST:@"/nonce/transaction"
                   parameters:parameters
                      success:^(__unused AFHTTPRequestOperation *operation, __unused id responseObject) {
                          completionBlock(responseObject[@"message"], nil);
                      }
                      failure:^(__unused AFHTTPRequestOperation *operation, __unused NSError *error) {
                          completionBlock(nil, error);
                      }];
}

@end
