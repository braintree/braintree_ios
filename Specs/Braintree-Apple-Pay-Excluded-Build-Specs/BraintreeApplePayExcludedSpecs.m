#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PassKit/PassKit.h>

#import <Braintree/Braintree.h>
#import <Braintree/BTPaymentProvider.h>
#import <Braintree/BTClient.h>

#import "BTTestClientTokenFactory.h"
#import <Braintree/BTClient+Offline.h>
#import "BTLogger_Internal.h"

@interface Braintree (BraintreeApplePayExcludedSpecsTestAddition)
- (void)tokenizeApplePayPayment:(id)payment
                     completion:(void (^)(NSString *, NSError *))completionBlock;
@end

@interface BraintreeApplePayExcludedSpecs : XCTestCase
@end

@implementation BraintreeApplePayExcludedSpecs

- (void)testBraintreeExcludesApplePay {
    OCMockObject *mockLogger = [OCMockObject partialMockForObject:[BTLogger sharedLogger]];
    [[mockLogger expect] warning:@"Apple Pay is not compiled into this integration of Braintree. Please ensure that BT_ENABLE_APPLE_PAY=1 in your framework and app targets."];
#if DEBUG
    XCTAssertThrowsSpecificNamed([self tokenizeApplePay], NSException, NSInternalInconsistencyException);
#else
    [self tokenizeApplePay];
#endif
    [mockLogger verify];
}

- (void)tokenizeApplePay {
    Braintree *braintree = [Braintree braintreeWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2]];
    [braintree tokenizeApplePayPayment:[PKPayment new] completion:^(NSString * __nullable nonce, NSError * __nullable error) {
    }];
}

- (void)testBTPaymentProviderExcludesApplePay {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2];
    Braintree *bt = [Braintree braintreeWithClientToken:clientToken];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];
    [[mockDelegate expect] paymentMethodCreator:OCMOCK_ANY didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        XCTAssertEqualObjects(error.domain, BTPaymentProviderErrorDomain);
        XCTAssertEqual(error.code, BTPaymentProviderErrorInitialization);
        return YES;
    }]];

    BTPaymentProvider *paymentProvider = [bt paymentProviderWithDelegate:mockDelegate];

    XCTAssertThrows([paymentProvider createPaymentMethod:BTPaymentProviderTypeApplePay]);

    [mockDelegate verify];
    [mockDelegate stopMocking];
}

- (void)testBTClientExcludesApplePay {
    XCTAssertFalse([BTClient instancesRespondToSelector:NSSelectorFromString(@"saveApplePayPayment:success:failure:")]);
}

@end
