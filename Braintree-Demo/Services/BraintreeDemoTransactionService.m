#import "BraintreeDemoTransactionService.h"
#import <AFNetworking/AFNetworking.h>

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
        self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://taprooted.herokuapp.com"]];
    }
    return self;
}

- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *, NSError *))completionBlock {
    NSString *customerId = [[NSUUID UUID] UUIDString];
    [self.sessionManager GET:@"/client_token"
                  parameters:@{@"customer_id": customerId}
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         completionBlock(operation.responseString, nil);
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         completionBlock(nil, error);
                     }];
}

- (void)makeTransactionWithPaymentMethodNonce:(NSString *)paymentMethodNonce completion:(void (^)(NSString *transactionId, NSError *error))completionBlock {
    [self.sessionManager POST:@"/nonce/transaction"
                   parameters:@{@"payment_method_nonce": paymentMethodNonce}
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          completionBlock(responseObject[@"message"], nil);
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          completionBlock(nil, error);
                      }];
}

@end
