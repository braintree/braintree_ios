#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Braintree/Braintree.h>
#import <Braintree/BTPaymentProvider.h>
#import <Braintree/BTClient.h>
#import <Braintree/BTClient+Offline.h>
#import <OCMock/OCMock.h>

@interface BraintreeApplePayExcludedSpecs : XCTestCase

@end

@implementation BraintreeApplePayExcludedSpecs

- (void)testBraintreeExcludesApplePay {
    XCTAssertFalse([Braintree instancesRespondToSelector:NSSelectorFromString(@"tokenizeApplePayPayment:completion:")]);
}

- (void)testBTPaymentProviderExcludesApplePay {
    Braintree *bt = [Braintree braintreeWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:@{}]];

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
