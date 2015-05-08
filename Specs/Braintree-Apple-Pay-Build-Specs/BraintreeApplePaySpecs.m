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
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2];
    Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];
    [[mockDelegate expect] paymentMethodCreator:OCMOCK_ANY requestsPresentationOfViewController:OCMOCK_ANY];

    BTPaymentProvider *paymentProvider = [braintree paymentProviderWithDelegate:mockDelegate];
    paymentProvider.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:@"A" amount:[NSDecimalNumber decimalNumberWithString:@"1"]]];
    [paymentProvider createPaymentMethod:BTPaymentProviderTypeApplePay];

    [mockDelegate verify];
    [mockDelegate stopMocking];
}

- (void)testBTClientIncludesApplePay {
    XCTAssertTrue([BTClient instancesRespondToSelector:@selector(saveApplePayPayment:success:failure:)]);
}

@end
