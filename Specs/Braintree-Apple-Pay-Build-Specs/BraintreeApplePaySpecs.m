#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Braintree/Braintree.h>
#import <Braintree/BTPaymentProvider.h>
#import <Braintree/BTClient.h>
#import <Braintree/BTClient+Offline.h>
#import <OCMock/OCMock.h>

@interface BraintreeApplePaySpecs : XCTestCase

@end

@implementation BraintreeApplePaySpecs

- (void)testBraintreeIncludesApplePay {
    XCTAssertTrue([Braintree instancesRespondToSelector:@selector(tokenizeApplePayPayment:completion:)]);
}

- (void)testBTPaymentProviderIncludesApplePay {
    Braintree *bt = [Braintree braintreeWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:@{}]];

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
