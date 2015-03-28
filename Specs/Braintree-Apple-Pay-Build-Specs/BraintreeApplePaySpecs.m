#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <Braintree/Braintree.h>
#import <Braintree/BTPaymentProvider.h>
#import <Braintree/BTClient.h>

#import "BTTestClientTokenFactory.h"

@interface BraintreeApplePaySpecs : XCTestCase

@end

@implementation BraintreeApplePaySpecs

- (void)testBraintreeIncludesApplePay {
    XCTAssertTrue([Braintree instancesRespondToSelector:@selector(tokenizeApplePayPayment:completion:)]);
}

- (void)testBTPaymentProviderIncludesApplePay {
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
    [[mockDelegate expect] paymentMethodCreator:OCMOCK_ANY requestsPresentationOfViewController:OCMOCK_ANY];

    BTPaymentProvider *paymentProvider = [bt paymentProviderWithDelegate:mockDelegate];
    paymentProvider.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:@"A" amount:[NSDecimalNumber decimalNumberWithString:@"1"]]];
    [paymentProvider createPaymentMethod:BTPaymentProviderTypeApplePay];

    [mockDelegate verify];
    [mockDelegate stopMocking];
}

- (void)testBTClientIncludesApplePay {
    XCTAssertTrue([BTClient instancesRespondToSelector:@selector(saveApplePayPayment:success:failure:)]);
}

@end
