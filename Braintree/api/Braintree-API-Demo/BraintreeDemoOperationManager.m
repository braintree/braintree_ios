#import "BraintreeDemoOperationManager.h"
#import "Braintree-API.h"
#import "BTClient+Offline.h"

@interface BraintreeDemoOperationManager ()
@property (nonatomic, strong) BTClient *client;
@end

@implementation BraintreeDemoOperationManager

+ (instancetype)manager {
    return [self new];
}

- (id)init {
    self = [super init];
    if (self) {
        self.client = [[BTClient alloc] initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:nil]];
    }
    return self;
}

- (BraintreeDemoClientOperation *)clientVersionOperation {
    BraintreeDemoClientOperation *operation = [BraintreeDemoClientOperation new];
    operation.name = @"Client Version";
    operation.block = ^(void (^callback)(NSString *result, NSError *error)){
        callback([BTClient libraryVersion], nil);
    };
    return operation;
}

- (BraintreeDemoClientOperation *)fetchPaymentMethodsOperation {
    BraintreeDemoClientOperation *operation = [BraintreeDemoClientOperation new];
    operation.name = @"Fetch Payment Methods";
    operation.block = ^(void (^callback)(NSArray *result, NSError *error)) {
        [self.client fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
            callback(paymentMethods, nil);
        } failure:^(NSError *error) {
            callback(nil, error);
        }];
    };
    return operation;
}

- (BraintreeDemoClientOperation *)saveCardOperation {
    BraintreeDemoClientOperation *operation = [BraintreeDemoClientOperation new];
    operation.name = @"Save New Card";
    operation.block = ^(void (^callback)(BTPaymentMethod *result, NSError *error)) {
        NSString *number = @"4111111111111111";
        NSString *expirationMonth = @"12";
        NSString *expirationYear = @"2038";
        [self.client saveCardWithNumber:number
                        expirationMonth:expirationMonth
                         expirationYear:expirationYear
                                    cvv:@"100"
                             postalCode:@"10000"
                               validate:YES
                                success:^(BTPaymentMethod *card) {
                                    callback(card, nil);
                                }
                                failure:^(NSError *error) {
                                    callback(nil,  error);
                                }];
    };

    return operation;
}

- (BraintreeDemoClientOperation *)reinitializeClientOperation {
    BraintreeDemoClientOperation *operation = [BraintreeDemoClientOperation new];
    operation.name = @"Reinitialize Client";
    operation.block = ^(void (^callback)(NSString *result, NSError *error)) {
        self.client = [[BTClient alloc] initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:nil]];
        callback(@"BTClient reset", nil);
    };

    return operation;
}

- (BraintreeDemoClientOperation *)saveInvalidCardOperation {
    BraintreeDemoClientOperation *operation = [BraintreeDemoClientOperation new];
    operation.name = @"Save Invalid Card";
    operation.block = ^(void (^callback)(id result, NSError *error)) {
        [self.client saveCardWithNumber:@"0000000000000000"
                        expirationMonth:@"99"
                         expirationYear:@"2038"
                                    cvv:@"100"
                             postalCode:@"10000"
                               validate:YES
                                success:^(BTPaymentMethod *card) {
                                    callback(card, nil);
                                }
                                failure:^(NSError *error) {
                                    callback(nil, error);
                                }];
    };
    return operation;
}

- (BraintreeDemoClientOperation *)savePayPalAccountOperation {
    BraintreeDemoClientOperation *operation = [BraintreeDemoClientOperation new];
    operation.name = @"Save PayPal Account";
    operation.block = ^(void (^callback)(id result, NSError *error)) {
        [self.client savePaypalPaymentMethodWithAuthCode:@"authCode" success:^(BTPayPalAccount *paypalAccount) {
            callback(paypalAccount, nil);
        } failure:^(NSError *error) {
            callback(nil, error);
        }];
    };
    return operation;
}

@end
