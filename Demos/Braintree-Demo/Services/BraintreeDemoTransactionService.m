#import "BraintreeDemoTransactionService.h"
#import <AFNetworking/AFNetworking.h>

NSString *BraintreeDemoTransactionServiceEnvironmentDidChangeNotification = @"BraintreeDemoTransactionServiceEnvironmentDidChangeNotification";

NSString *BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey = @"BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey";
NSString *BraintreeDemoTransactionServiceEnableThreeDSecureDefaultsKey = @"BraintreeDemoTransactionServiceEnableThreeDSecureDefaultsKey";
NSString *BraintreeDemoTransactionServiceRequireThreeDSecureDefaultsKey = @"BraintreeDemoTransactionServiceRequireThreeDSecureDefaultsKey";

typedef NS_ENUM(NSInteger, BraintreeDemoTransactionServiceThreeDSecureRequiredStatus) {
    BraintreeDemoTransactionServiceThreeDSecureRequiredStatusDefault = 0,
    BraintreeDemoTransactionServiceThreeDSecureRequiredStatusRequired = 1,
    BraintreeDemoTransactionServiceThreeDSecureRequiredStatusNotRequired = 2,
};


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
        [self setupSessionManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSessionManager) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)setupSessionManager {
    switch (self.currentEnvironment) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://braintree-sample-merchant.herokuapp.com"]];
            break;
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://executive-sample-merchant.herokuapp.com"]];
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:BraintreeDemoTransactionServiceEnvironmentDidChangeNotification object:self];
}

- (BraintreeDemoTransactionServiceEnvironment)currentEnvironment {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoTransactionServiceDefaultEnvironmentUserDefaultsKey];
}

- (BOOL)threeDSecureEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:BraintreeDemoTransactionServiceEnableThreeDSecureDefaultsKey];
}

- (BraintreeDemoTransactionServiceThreeDSecureRequiredStatus)threeDSecureRequiredStatus {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoTransactionServiceRequireThreeDSecureDefaultsKey];
}

- (NSString *)merchantAccountId {
    if (self.currentEnvironment == BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant && self.threeDSecureEnabled) {
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
    NSDictionary *parameters;

    switch (self.threeDSecureRequiredStatus) {
        case BraintreeDemoTransactionServiceThreeDSecureRequiredStatusDefault:
            parameters = @{ @"payment_method_nonce": paymentMethodNonce };
            break;
        case BraintreeDemoTransactionServiceThreeDSecureRequiredStatusRequired:
            parameters = @{ @"payment_method_nonce": paymentMethodNonce, @"require_three_d_secure": @YES, };
            break;
        case BraintreeDemoTransactionServiceThreeDSecureRequiredStatusNotRequired:
            parameters = @{ @"payment_method_nonce": paymentMethodNonce, @"require_three_d_secure": @NO, };
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
