#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

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
    Braintree *bt = [Braintree braintreeWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:@{}]];
    [bt tokenizeApplePayPayment:nil completion:nil];
}

- (void)testBTPaymentProviderExcludesApplePay {
    XCTestExpectation *setupExpectation = [self expectationWithDescription:@"Setup Braintree"];
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2];
    __block Braintree *bt;
    [Braintree setupWithClientToken:clientToken
                                         completion:^(Braintree *braintree, NSError *error) {
                                             bt = braintree;
                                             [setupExpectation fulfill];
                                         }];
    [self waitForExpectationsWithTimeout:10 handler:nil];

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
