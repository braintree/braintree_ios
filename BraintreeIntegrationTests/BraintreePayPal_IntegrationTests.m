#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreePayPal/BraintreePayPal.h>
#import <BraintreePayPal/BTPayPalDriver_Internal.h>
#import "BTIntegrationTestsHelper.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>


id OCMArgCheckURLSchemeBeginsWith(NSString *string) {
    return [OCMArg checkWithBlock:^BOOL(NSURL *url) {
        return [url.scheme hasPrefix:string];
    }];
}

@interface BTPayPalDriverTestDelegate : NSObject <BTAppSwitchDelegate>
@property (nonatomic, strong) XCTestExpectation *willPerform;
@property (nonatomic, strong) XCTestExpectation *didPerform;
@property (nonatomic, strong) XCTestExpectation *willProcess;
@property (nonatomic, strong) id lastAppSwitcher;
@property (nonatomic, assign) BTAppSwitchTarget lastTarget;
@end

@implementation BTPayPalDriverTestDelegate

- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher {
    self.lastAppSwitcher = appSwitcher;
    [self.willPerform fulfill];
}

- (void)appSwitcher:(id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target {
    self.lastTarget = target;
    self.lastAppSwitcher = appSwitcher;
    [self.didPerform fulfill];
}

- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher {
    self.lastAppSwitcher = appSwitcher;
    [self.willProcess fulfill];
}

@end

@interface BraintreePayPal_IntegrationTests : XCTestCase
@property (nonatomic, strong) NSNumber *didReceiveCompletionCallback;
@end


@implementation BraintreePayPal_IntegrationTests

NSString * const OneTouchCoreAppSwitchSuccessURLFixture = @"com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoyLCJhY2NvdW50X2NvdW50cnkiOiJVUyIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXhwaXJlc19pbiI6LTEsImRpc3BsYXlfbmFtZSI6Im1vY2tEaXNwbGF5TmFtZSIsInNjb3BlIjoiaHR0cHM6XC9cL3VyaS5wYXlwYWwuY29tXC9zZXJ2aWNlc1wvcGF5bWVudHNcL2Z1dHVyZXBheW1lbnRzIiwiZW1haWwiOiJtb2NrZW1haWxhZGRyZXNzQG1vY2suY29tIiwiYXV0aG9yaXphdGlvbl9jb2RlIjoibW9ja1RoaXJkUGFydHlBdXRob3JpemF0aW9uQ29kZSJ9&x-source=com.paypal.ppclient.touch.v1-or-v2";

#pragma mark - Authorization (Future Payments)

- (void)testFuturePayments_whenPayPalAppIsInstalled_performsAppSwitchToApp {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    // Since we're stubbing UIApplication canOpenURL to say YES to everything, PayPalOneTouchCore will believe
    // that both browser switch and app switch are available
    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform App Switch"];
    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"com.paypal")]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_whenPayPalAppIsNotInstalled_performsAppSwitchToBrowser {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    // Must be careful about stubbing canOpenURL: to do the following:
    //  * Return YES for "https" for browser switch
    //  * Return YES for "com.braintreepayments.Demo.payments" for PayPalOneTouchCore, which validates that
    //    the return URL has been set up correctly
    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andReturn(YES);
    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"com.braintreepayments.Demo.payments")]).andReturn(YES);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform App Switch"];
    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_whenPayPalIsNotEnabledInControlPanel_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration2_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeDisabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_whenReturnURLSchemeIsMissing_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeIntegrationReturnURLScheme);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}


- (void)testFuturePayments_whenReturnURLSchemeIsInvalid_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"not-my-app-bundle-id";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeIntegrationReturnURLScheme);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_onSuccessfulAppSwitchAuthorization_returnsTokenizedPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    XCTestExpectation *expectation = [self expectationWithDescription:@"App switch occurred"];
    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"com.paypal")]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertTrue(tokenizedPayPalAccount.paymentMethodNonce.isANonce);
        XCTAssertNil(error);
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoxLCJlbnZpcm9ubWVudCI6Im1vY2siLCJhdXRob3JpemF0aW9uX2NvZGUiOiJtb2NrVGhpcmRQYXJ0eUF1dGhvcml6YXRpb25Db2RlIiwicmVzcG9uc2VfdHlwZSI6ImNvZGUiLCJzY29wZSI6ImVtYWlsIGh0dHBzOlwvXC91cmkucGF5cGFsLmNvbVwvc2VydmljZXNcL3BheW1lbnRzXC9mdXR1cmVwYXltZW50cyIsImVtYWlsIjoibW9ja2VtYWlsYWRkcmVzc0Btb2NrLmNvbSIsImFjY291bnRfY291bnRyeSI6IlVTIiwiZGlzcGxheV9uYW1lIjoibW9ja0Rpc3BsYXlOYW1lIiwiYWNjZXNzX3Rva2VuIjoiIiwibGFuZ3VhZ2UiOiJlbl9VUyIsImV4cGlyZXNfaW4iOi0xfQ%3D%3D&x-source=com.yourcompany.PPClient"]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// FIXME: Revisit this when Braintree browser switch supports client key
- (void)pendFuturePayments_onSuccessfulBrowserSwitchAuthorization_returnsTokenizedPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andReturn(YES);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Browser switch occurred"];
    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    self.didReceiveCompletionCallback = nil;
    
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertTrue(tokenizedPayPalAccount.paymentMethodNonce.isANonce);
        XCTAssertNil(error);
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    // From Demo app
    NSURL *validUrl = [NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/success?payloadEnc=t4XttSmQAJLKnuGiA8ho5%2F%2F8rAHUwTt5AZWLJtjdNh%2BmjcLqOblmDwzRa2qswVn2SkcPVIAe57WaYt0%2FeBJrSMGgDohij2Cqi0NMkpNzCj2ausVmc41kROmFUS3sD6GzOWr0c%2Bz%2FU4dPEWVRbwClTgap%2B%2BftAcrozfYWAkZBu7wGlQ26FEejIfTq3ZUwkU%2FbdRk8yg%2B3rxlYLBUKdWAJoOgqNBmLNV%2BvfKKOI0u0eGKwLzNlSbz%2BIWLjTlk1JKcKpPxuEETNR0Nik2BgdGgCJil5jJ5poErA2YWkwH5EBjR3JvEk4wDpZzni0UlM120g1ByZP9axACxCSDDJQ6qlgTmNGJ%2Bq0T6LDrMcwhKCg%2BbyF0f3c4un3eO0K3M2Fo0P6WkfgPvAHp7MHfCDUpHoYA%3D%3D&payload=eyJ2ZXJzaW9uIjozLCJtc2dfR1VJRCI6IkQwREQ2M0M5LTc4NkMtNEU1Ny1CNUE3LTZFOUVCMzgwQTIwRiIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXJyb3IiOm51bGx9&x-source=com.braintree.browserswitch"];

    NSString *source = @"com.apple.mobilesafari";

    // FIXME: PayPal OTC says it can handle the URL, but it actually can't
    BOOL canHandle = [BTPayPalDriver canHandleAppSwitchReturnURL:validUrl sourceApplication:source];
    XCTAssertTrue(canHandle);
    [BTPayPalDriver handleAppSwitchReturnURL:validUrl];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_onCancelledAppSwitchAuthorization_callsBackWithNoTokenizedAccountOrError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    XCTestExpectation *expectation = [self expectationWithDescription:@"App switch occurred"];
    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"com.paypal")]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertNil(error);
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/cancel?payload=eyJ2ZXJzaW9uIjozLCJtc2dfR1VJRCI6IjQ1QUZEQkE3LUJEQTYtNDNEMi04MUY2LUY4REM1QjZEOTkzQSIsImVudmlyb25tZW50IjoibW9jayJ9&x-source=com.paypal.ppclient.touch.v2"]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Analytics

// MARK: Analytics

- (void)testAnalytics_whenInitiatingFuturePayments_postsExpectedEventBeforePerformingAppSwitch {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    // BTPayPalDriver copies APIClient, so we have to mock the API client after the call to initWithAPIClient
    id partialMockAPIClient = OCMPartialMock(payPalDriver.apiClient);
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);

    // App switch target iOS app
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;
    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        XCTAssertNil(error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    OCMVerify([partialMockAPIClient postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.started"]);
}
// TODO: Add more tests for analytics

#pragma mark - Checkout (Single Payments)

// TODO: Client Key does not have permissions to perform PayPal Single Payments
// (because /paypal_hermes/create_payment_resource doesn't have enough)
//- (void)testCheckout_whenPayPalAppIsInstalled_performsAppSwitchToApp {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
//    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
//    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform App Switch"];
//    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"com.paypal")]).andDo(^(__unused NSInvocation *invocation) {
//        [expectation fulfill];
//    });
//
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"] ];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        if (error) {
//            XCTFail(@"%@", error);
//        }
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//
//- (void)testCheckout_whenPayPalAppIsNotInstalled_performsAppSwitchToBrowser {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
//    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
//    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andReturn(YES);
//    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"com.braintreepayments.Demo.payments")]).andReturn(YES);
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform App Switch"];
//    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andDo(^(NSInvocation *invocation) {
//        [expectation fulfill];
//    });
//
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        if (error) {
//            XCTFail(@"%@", error);
//        }
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//- (void)testCheckout_whenPayPalIsNotEnabledInControlPanel_returnsError {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration2_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        XCTAssertNil(tokenizedPayPalCheckout);
//        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
//        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeDisabled);
//        [expectation fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//- (void)testCheckout_whenReturnURLSchemeIsMissing_returnsError {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        XCTAssertNil(tokenizedPayPalCheckout);
//        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
//        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeIntegrationReturnURLScheme);
//        [expectation fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//
//- (void)testCheckout_whenReturnURLSchemeIsInvalid_returnsError {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//    [BTAppSwitch sharedInstance].returnURLScheme = @"not-my-app-bundle-id";
//
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        XCTAssertNil(tokenizedPayPalCheckout);
//        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
//        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeIntegrationReturnURLScheme);
//        [expectation fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//- (void)testCheckout_onSuccessfulAppSwitchAuthorization_returnsTokenizedPayPalCheckout {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
//    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
//    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
//    XCTestExpectation *expectation = [self expectationWithDescription:@"App switch occurred"];
//    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"com.paypal")]).andDo(^(__unused NSInvocation *invocation) {
//        [expectation fulfill];
//    });
//
//    self.didReceiveCompletionCallback = nil;
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error) {
//        XCTAssertTrue(tokenizedPayPalCheckout.paymentMethodNonce.isANonce);
//        XCTAssertNil(error);
//        self.didReceiveCompletionCallback = @(YES);
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//
//    // FIXME
//    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"get actual app switch URL"]];
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
//    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//- (void)testCheckout_onSuccessfulBrowserSwitchAuthorization_returnsTokenizedPayPalCheckout {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
//    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
//    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andReturn(YES);
//    XCTestExpectation *expectation = [self expectationWithDescription:@"App switch occurred"];
//    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andDo(^(__unused NSInvocation *invocation) {
//        [expectation fulfill];
//    });
//
//    self.didReceiveCompletionCallback = nil;
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        XCTAssertTrue(tokenizedPayPalCheckout.paymentMethodNonce.isANonce);
//        XCTAssertNil(error);
//        self.didReceiveCompletionCallback = @(YES);
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//
//    // FIXME
//    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"get actual browser switch URL"]];
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
//    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//- (void)testFuturePayments_onCancelledAppSwitchAuthorization_returnsNothing {
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
//    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
//    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
//    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
//    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
//    XCTestExpectation *expectation = [self expectationWithDescription:@"App switch occurred"];
//    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"com.paypal")]).andDo(^(__unused NSInvocation *invocation) {
//        [expectation fulfill];
//    });
//
//    self.didReceiveCompletionCallback = nil;
//    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//    [payPalDriver checkoutWithCheckoutRequest:request completion:^(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error) {
//        XCTAssertTrue(tokenizedPayPalCheckout.paymentMethodNonce.isANonce);
//        XCTAssertNil(error);
//        self.didReceiveCompletionCallback = @(YES);
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//
//    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/cancel?payload=eyJ2ZXJzaW9uIjozLCJtc2dfR1VJRCI6IjQ1QUZEQkE3LUJEQTYtNDNEMi04MUY2LUY4REM1QjZEOTkzQSIsImVudmlyb25tZW50IjoibW9jayJ9&x-source=com.paypal.ppclient.touch.v2"]];
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
//    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}

#pragma mark - Delegate calls

// TODO

#pragma mark - Return URL handling

#pragma mark canHandleURL

- (void)testCanHandleAppSwitchReturnURL_forURLsFromBrowserSwitch_returnsYES {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;

    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/success?payloadEnc=e0yvzQHOOoXyoLjKZvHBI0Rbyad6usxhOz22CjG3V1lOsguMRsuQpEqPxlIlK86VPmTuagb1jJcnDUK9QsWJE8ffe4i9Ms4ggd6r5EoymVM%2BAYgjyjaYtPPOxIgMepNGnvnYt9EKJs2Bd0wbZj0ekxSA6BzRZDPEpZ%2FjhssxJVscjbPvOwCoTnjEhuNxiOamAGSRd6fo7ln%2BishDwRCLz81qlV8cgfXNzlHrRw1P7CbTQ8XhNGn35CHD64ysuHAW97ZjAzPCRdikWbgiw2S%2BDvSePhRRnTR10e2NPDYBeVzGQFzvf6WRklrqcLeFwRcAqoa0ZneOPgMbk5nvylGY716caCCPtJKnoJAflZZK6%2F7iXcA%2F3p9qrQIrszmthu%2FbnA%2FP7dZsWRarUiT%2FZhZg32MsmV3B3fPjQOMbhB7dRv5uomhCjhNhPzXH7nFA54mKOlvAdTm1QOk5P%2Fh3AaHz0qwIKgXAhxIfwxqHgIYxtba53sdwa7OXfx14FRlcfPngrR02IAHeaulkH6vJ24ZAsoUUdNkvRfDmM1O2%2B4424%2FMINTUJJsR0%2FwrYrwzp0gC6fKoAzT%2FgFhL6QVLoUss%3D&payload=eyJ2ZXJzaW9uIjozLCJtc2dfR1VJRCI6IkMwQTkwODQ1LTJBRUQtNEZCRC04NzIwLTQzNUU2MkRGNjhFNCIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJsaXZlIiwiZXJyb3IiOm51bGx9&x-source=com.braintree.browserswitch"];
    NSString *source = @"com.apple.mobilesafari";

    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:source];

    XCTAssertTrue(canHandleAppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_forURLsFromAppSwitch_returnsYES {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    BOOL canHandleV1AppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.paypal.ppclient.touch.v1"];
    BOOL canHandleV2AppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.paypal.ppclient.touch.v2"];

    XCTAssertTrue(canHandleV1AppSwitch);
    XCTAssertTrue(canHandleV2AppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_forMalformedURLs_returnsNO {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    // This malformed returnURL is just missing payload
    NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/success?x-source=com.paypal.ppclient.touch.v1-or-v2"];
    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.paypal.ppclient.touch.v1"];

    XCTAssertFalse(canHandleAppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_whenNoAppSwitchIsInProgress_returnsNO {
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.malicious.app"];

    XCTAssertFalse(canHandleAppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_afterHandlingAnAppSwitchAndBeforeInitiatingAnotherAppSwitch_returnsNO {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.paypal.ppclient.touch.v1"];
    XCTAssertTrue(canHandleAppSwitch);
    [BTPayPalDriver handleAppSwitchReturnURL:returnURL];

    // Pause until handleAppSwitchReturnURL has finished
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];

    canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.paypal.ppclient.touch.v1"];
    XCTAssertFalse(canHandleAppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_whenAppSwitchReturnURLHasMismatchedCase_returnsYES {
    // Motivation for this test is because of Safari's habit of downcasing URL schemes
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;

    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/success?payloadEnc=e0yvzQHOOoXyoLjKZvHBI0Rbyad6usxhOz22CjG3V1lOsguMRsuQpEqPxlIlK86VPmTuagb1jJcnDUK9QsWJE8ffe4i9Ms4ggd6r5EoymVM%2BAYgjyjaYtPPOxIgMepNGnvnYt9EKJs2Bd0wbZj0ekxSA6BzRZDPEpZ%2FjhssxJVscjbPvOwCoTnjEhuNxiOamAGSRd6fo7ln%2BishDwRCLz81qlV8cgfXNzlHrRw1P7CbTQ8XhNGn35CHD64ysuHAW97ZjAzPCRdikWbgiw2S%2BDvSePhRRnTR10e2NPDYBeVzGQFzvf6WRklrqcLeFwRcAqoa0ZneOPgMbk5nvylGY716caCCPtJKnoJAflZZK6%2F7iXcA%2F3p9qrQIrszmthu%2FbnA%2FP7dZsWRarUiT%2FZhZg32MsmV3B3fPjQOMbhB7dRv5uomhCjhNhPzXH7nFA54mKOlvAdTm1QOk5P%2Fh3AaHz0qwIKgXAhxIfwxqHgIYxtba53sdwa7OXfx14FRlcfPngrR02IAHeaulkH6vJ24ZAsoUUdNkvRfDmM1O2%2B4424%2FMINTUJJsR0%2FwrYrwzp0gC6fKoAzT%2FgFhL6QVLoUss%3D&payload=eyJ2ZXJzaW9uIjozLCJtc2dfR1VJRCI6IkMwQTkwODQ1LTJBRUQtNEZCRC04NzIwLTQzNUU2MkRGNjhFNCIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJsaXZlIiwiZXJyb3IiOm51bGx9&x-source=com.braintree.browserswitch"];
    NSString *source = @"com.apple.mobilesafari";
    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:source];

    XCTAssertTrue(canHandleAppSwitch);
}

#pragma mark handleURL

- (void)testHandleURL_whenURLIsConsideredInvalidByPayPalOTC_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertNotNil(error);
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.braintreepayments.Demo.payments://----invalid----"]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testHandleURL_whenURLIsMissingHostAndPath_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTPayPalDriverTestDelegate *delegate = [[BTPayPalDriverTestDelegate alloc] init];
    delegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
    delegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
    payPalDriver.delegate = delegate;
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertNotNil(error);
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.braintreepayments.Demo.payments://"]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// This doesn't seem to be a valid case
//    it(@"accepts a failure app switch return", ^{
//
//        [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
//            [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];
//
//            // Both -canOpenURL: and -openURL: are checked by OTC
//            [[[mockApplication stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", @"com.paypal.ppclient.touch.v2")];
//            [[[mockApplication stub] andReturnValue:@YES] openURL:HC_hasProperty(@"scheme", @"com.paypal.ppclient.touch.v2")];
//
//            BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];
//
//            [payPalDriver startAuthorizationWithCompletion:nil];
//
//            NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.braintree-demo.PaYmEnTs://onetouch/v1/failure?error=some+message"];
//
//            XCTestExpectation *parseOtcExpectation = [self expectationWithDescription:@"Parse otc response"];
//
//            [PayPalOneTouchCore parseResponseURL:returnURL
//                                 completionBlock:^(PayPalOneTouchCoreResult *result) {
//                                     expect(result.type).to.equal(PayPalOneTouchResultTypeError);
//                                     [parseOtcExpectation fulfill];
//                                 }];
//
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//
//            [mockClient verify];
//        }];

/*

SpecBegin(BTPayPalDriver)

describe(@"PayPal One Touch Core", ^{
    describe(@"future payments", ^{


        describe(@"analytics", ^{
            it(@"posts an analytics event for a successful app switch to the PayPal app", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    XCTestExpectation *appSwitchExpectation = [self expectationWithDescription:@"Perform App Switch"];
                    [[[mockApplication stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", HC_startsWith(@"com.paypal"))];
                    [[[[mockApplication expect] andReturnValue:@YES] andDo:^(__unused NSInvocation *invocation) {
                        [appSwitchExpectation fulfill];
                    }] openURL:HC_hasProperty(@"scheme", HC_startsWith(@"com.paypal"))];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];

                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.started"];

                    [payPalDriver startAuthorizationWithCompletion:nil];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                    [mockClient verify];
                }];
            });

            it(@"posts an analytics event for a successful app switch to the Browser", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    XCTestExpectation *appSwitchExpectation = [self expectationWithDescription:@"Perform App Switch"];
                    [[[mockApplication stub] andReturnValue:@NO] canOpenURL:HC_hasProperty(@"scheme", HC_startsWith(@"com.paypal"))];
                    [[[mockApplication stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", @"https")];
                    [[[[mockApplication expect] andReturnValue:@YES] andDo:^(__unused NSInvocation *invocation) {
                        [appSwitchExpectation fulfill];
                    }] openURL:HC_hasProperty(@"scheme", @"https")];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];

                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];

                    [payPalDriver startAuthorizationWithCompletion:nil];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                    [mockClient verify];
                }];
            });

            it(@"posts an analytics event for a failed app switch", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    XCTestExpectation *appSwitchExpectation = [self expectationWithDescription:@"Perform App Switch"];
                    [[[mockApplication stub] andReturnValue:@NO] canOpenURL:HC_hasProperty(@"scheme", HC_startsWith(@"com.paypal"))];
                    [[[mockApplication stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", @"https")];
                    [[[[mockApplication expect] andReturnValue:@YES] andDo:^(__unused NSInvocation *invocation) {
                        [appSwitchExpectation fulfill];
                    }] openURL:HC_hasProperty(@"scheme", @"https")];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];

                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];

                    [payPalDriver startAuthorizationWithCompletion:nil];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                    [mockClient verify];
                }];
            });

            it(@"posts analytics events when preflight checks fail", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:@"invalid-return-url-scheme"];
                    expect(payPalDriver).to.beNil();

                    [mockClient verify];
                }];
            });

            it(@"post an analytics event to indicate handling the one touch core response ", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    NSURL *fakeReturnURL = [OCMockObject mockForClass:[NSURL class]];

                    [[[mockApplication stub] andReturnValue:@YES] canOpenURL:OCMOCK_ANY];
                    [[[mockApplication stub] andReturnValue:@YES] openURL:OCMOCK_ANY];

                    id mockOTC = [OCMockObject mockForClass:[PayPalOneTouchCore class]];
                    [[[[mockOTC stub] classMethod] andDo:^(NSInvocation *invocation) {
                        void (^stubOTCCompletionBlock)(PayPalOneTouchCoreResult *result);
                        [invocation getArgument:&stubOTCCompletionBlock atIndex:3];
                        id result = [OCMockObject mockForClass:[PayPalOneTouchCoreResult class]];
                        [(PayPalOneTouchCoreResult *)[[result stub] andReturnValue:OCMOCK_VALUE(PayPalOneTouchResultTypeCancel)] type];
                        [(PayPalOneTouchCoreResult *)[result stub] target];
                        [(PayPalOneTouchCoreResult *)[result stub] error];
                        stubOTCCompletionBlock(result);
                    }] parseResponseURL:fakeReturnURL completionBlock:[OCMArg isNotNil]];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];

                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled"];
                    [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];

                    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Received call to completion block"];
                    [payPalDriver startAuthorizationWithCompletion:^void(BTPayPalPaymentMethod *paymentMethod, NSError *error) {
                        [completionExpectation fulfill];
                    }];

                    [BTPayPalDriver handleAppSwitchReturnURL:fakeReturnURL];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                    [mockClient verify];
                }];
            });

            it(@"posts an anlaytics event to indicate tokenization success", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    NSURL *fakeReturnURL = [OCMockObject mockForClass:[NSURL class]];

                    [[[mockClient stub] andDo:^(NSInvocation *invocation) {
                        void (^successBlock)(BTPaymentMethod *paymentMethod);
                        [invocation getArgument:&successBlock atIndex:4];
                        successBlock(nil);
                    }] savePaypalAccount:OCMOCK_ANY clientMetadataID:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];

                    [[[mockApplication stub] andReturnValue:@YES] canOpenURL:OCMOCK_ANY];
                    [[[mockApplication stub] andReturnValue:@YES] openURL:OCMOCK_ANY];

                    id mockOTC = [OCMockObject mockForClass:[PayPalOneTouchCore class]];
                    [[[[mockOTC stub] classMethod] andDo:^(NSInvocation *invocation) {
                        void (^stubOTCCompletionBlock)(PayPalOneTouchCoreResult *result);
                        [invocation getArgument:&stubOTCCompletionBlock atIndex:3];
                        id result = [OCMockObject mockForClass:[PayPalOneTouchCoreResult class]];
                        [(PayPalOneTouchCoreResult *)[[result stub] andReturnValue:OCMOCK_VALUE(PayPalOneTouchResultTypeSuccess)] type];
                        [(PayPalOneTouchCoreResult *)[result stub] target];
                        [(PayPalOneTouchCoreResult *)[result stub] response];
                        stubOTCCompletionBlock(result);
                    }] parseResponseURL:fakeReturnURL completionBlock:[OCMArg isNotNil]];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];

                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.succeeded"];
                    [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];

                    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Received call to completion block"];
                    [payPalDriver startAuthorizationWithCompletion:^void(BTPayPalPaymentMethod *paymentMethod, NSError *error) {
                        [completionExpectation fulfill];
                    }];

                    [BTPayPalDriver handleAppSwitchReturnURL:fakeReturnURL];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                    [mockClient verify];
                }];
            });

            it(@"posts an anlaytics event to indicate tokenization failure", ^{
                [BTPayPalDriverSpecHelper setupSpec:^(NSString *returnURLScheme, id mockClient, id mockApplication){
                    NSURL *fakeReturnURL = [OCMockObject mockForClass:[NSURL class]];

                    [[[mockClient stub] andDo:^(NSInvocation *invocation) {
                        void (^failureBlock)(BTPaymentMethod *paymentMethod);
                        [invocation getArgument:&failureBlock atIndex:5];
                        failureBlock(nil);
                    }] savePaypalAccount:OCMOCK_ANY clientMetadataID:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];

                    [[[mockApplication stub] andReturnValue:@YES] canOpenURL:OCMOCK_ANY];
                    [[[mockApplication stub] andReturnValue:@YES] openURL:OCMOCK_ANY];

                    id mockOTC = [OCMockObject mockForClass:[PayPalOneTouchCore class]];
                    [[[[mockOTC stub] classMethod] andDo:^(NSInvocation *invocation) {
                        void (^stubOTCCompletionBlock)(PayPalOneTouchCoreResult *result);
                        [invocation getArgument:&stubOTCCompletionBlock atIndex:3];
                        id result = [OCMockObject mockForClass:[PayPalOneTouchCoreResult class]];
                        [(PayPalOneTouchCoreResult *)[[result stub] andReturnValue:OCMOCK_VALUE(PayPalOneTouchResultTypeSuccess)] type];
                        [(PayPalOneTouchCoreResult *)[result stub] target];
                        [(PayPalOneTouchCoreResult *)[result stub] response];
                        stubOTCCompletionBlock(result);
                    }] parseResponseURL:fakeReturnURL completionBlock:[OCMArg isNotNil]];

                    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithClient:mockClient returnURLScheme:returnURLScheme];

                    [[mockClient expect] postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.failed"];
                    [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];

                    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Received call to completion block"];
                    [payPalDriver startAuthorizationWithCompletion:^void(BTPayPalPaymentMethod *paymentMethod, NSError *error) {
                        [completionExpectation fulfill];
                    }];

                    [BTPayPalDriver handleAppSwitchReturnURL:fakeReturnURL];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                    [mockClient verify];
                }];
            });
        });

        describe(@"delegate notifications", ^{
        });

        describe(@"isAvailable", ^{


            it(@"returns YES when PayPal is enabled in configuration and One Touch Core is ready", ^{

                id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
                [[[configuration stub] andReturnValue:@YES] payPalEnabled];
                [[[configuration stub] andReturn:[NSURL URLWithString:@"https://example.com/privacy"]] payPalPrivacyPolicyURL];
                [[[configuration stub] andReturn:[NSURL URLWithString:@"https://example.com/tos"]] payPalMerchantUserAgreementURL];
                [[[configuration stub] andReturn:@"offline"] payPalEnvironment];
                [[[configuration stub] andReturn:@"client-id"] payPalClientId];

                id clientToken = [OCMockObject mockForClass:[BTClientToken class]];
                [[[clientToken stub] andReturn:@"client-token"] originalValue];

                id client = [OCMockObject mockForClass:[BTClient class]];
                [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
                [[[client stub] andReturn:clientToken] clientToken];
                [[[client stub] andReturn:configuration] configuration];

                NSString *returnURLScheme = @"com.braintreepayments.Braintree-Demo.bt-payments";

                id bundle = [OCMockObject partialMockForObject:[NSBundle mainBundle]];
                [[[bundle stub] andReturn:@[@{ @"CFBundleURLSchemes": @[returnURLScheme] }]] objectForInfoDictionaryKey:@"CFBundleURLTypes"];

                id application = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                [[[application stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", returnURLScheme)];

                NSError *error;
                BOOL isAvailable = [BTPayPalDriver verifyAppSwitchConfigurationForClient:client returnURLScheme:returnURLScheme error:&error];
                expect(isAvailable).to.beTruthy();
                expect(error).to.beNil();


            });

            it(@"returns NO when PayPal is not enabled in configuration", ^{

                id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
                [[[configuration stub] andReturnValue:@NO] payPalEnabled];

                [[[configuration stub] andReturn:@"offline"] payPalEnvironment];
                [[[configuration stub] andReturn:@"client-id"] payPalClientId];

                id clientToken = [OCMockObject mockForClass:[BTClientToken class]];
                [[[clientToken stub] andReturn:@"client-token"] originalValue];

                id client = [OCMockObject mockForClass:[BTClient class]];
                [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
                [[[client stub] andReturn:clientToken] clientToken];
                [[[client stub] andReturn:configuration] configuration];

                NSString *returnURLScheme = @"com.braintreepayments.Braintree-Demo.bt-payments";

                id bundle = [OCMockObject partialMockForObject:[NSBundle mainBundle]];
                [[[bundle stub] andReturn:@[@{ @"CFBundleURLSchemes": @[returnURLScheme] }]] objectForInfoDictionaryKey:@"CFBundleURLTypes"];

                id application = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                [[[application stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", returnURLScheme)];

                [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
                
                NSError *error;
                BOOL isAvailable = [BTPayPalDriver verifyAppSwitchConfigurationForClient:client returnURLScheme:returnURLScheme error:&error];
                expect(isAvailable).to.beFalsy();
                expect(error).notTo.beNil();
                
            });
            
            it(@"returns NO when the URL scheme has not been setup", ^{
                
                id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
                [[[configuration stub] andReturnValue:@YES] payPalEnabled];
                
                [[[configuration stub] andReturn:@"offline"] payPalEnvironment];
                [[[configuration stub] andReturn:@"client-id"] payPalClientId];
                
                id clientToken = [OCMockObject mockForClass:[BTClientToken class]];
                [[[clientToken stub] andReturn:@"client-token"] originalValue];
                
                id client = [OCMockObject mockForClass:[BTClient class]];
                [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
                [[[client stub] andReturn:clientToken] clientToken];
                [[[client stub] andReturn:configuration] configuration];
                
                NSString *returnURLScheme = @"com.braintreepayments.Braintree-Demo.bt-payments";
                
                id application = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                [[[application stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", returnURLScheme)];
                
                [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
                
                NSError *error;
                BOOL isAvailable = [BTPayPalDriver verifyAppSwitchConfigurationForClient:client returnURLScheme:returnURLScheme error:&error];
                expect(isAvailable).to.beFalsy();
                expect(error).notTo.beNil();
                
            });
            
            it(@"returns NO when the return URL scheme has not been registered with UIApplication", ^{
                
                id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
                [[[configuration stub] andReturnValue:@YES] payPalEnabled];
                
                [[[configuration stub] andReturn:@"offline"] payPalEnvironment];
                [[[configuration stub] andReturn:@"client-id"] payPalClientId];
                
                id clientToken = [OCMockObject mockForClass:[BTClientToken class]];
                [[[clientToken stub] andReturn:@"client-token"] originalValue];
                
                id client = [OCMockObject mockForClass:[BTClient class]];
                [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
                [[[client stub] andReturn:clientToken] clientToken];
                [[[client stub] andReturn:configuration] configuration];
                
                NSString *returnURLScheme = @"com.braintreepayments.Braintree-Demo.bt-payments";
                
                id bundle = [OCMockObject partialMockForObject:[NSBundle mainBundle]];
                [[[bundle stub] andReturn:@[@{ @"CFBundleURLSchemes": @[returnURLScheme] }]] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
                
                [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
                
                NSError *error;
                BOOL isAvailable = [BTPayPalDriver verifyAppSwitchConfigurationForClient:client returnURLScheme:returnURLScheme error:&error];
                expect(isAvailable).to.beFalsy();
                expect(error).notTo.beNil();
                
            });
        });
        
    });
    
    
});
});
@implementation BTPayPalDriverSpecHelper

+ (void)setupSpec:(void (^)(NSString *returnURLScheme, id mockClient, id mockApplication))setupBlock {
    id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
    [[[configuration stub] andReturnValue:@YES] payPalEnabled];
    [[[configuration stub] andReturn:[NSURL URLWithString:@"https://example.com/privacy"]] payPalPrivacyPolicyURL];
    [[[configuration stub] andReturn:[NSURL URLWithString:@"https://example.com/tos"]] payPalMerchantUserAgreementURL];
    [[[configuration stub] andReturn:@"offline"] payPalEnvironment];
    [[[configuration stub] andReturn:@"client-id"] payPalClientId];
    
    id clientToken = [OCMockObject mockForClass:[BTClientToken class]];
    [[[clientToken stub] andReturn:@"client-token"] originalValue];
    
    id client = [OCMockObject mockForClass:[BTClient class]];
    [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
    [[[client stub] andReturn:clientToken] clientToken];
    [[[client stub] andReturn:configuration] configuration];
    
    NSString *returnURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    
    id bundle = [OCMockObject partialMockForObject:[NSBundle mainBundle]];
    [[[bundle stub] andReturn:@[@{ @"CFBundleURLSchemes": @[returnURLScheme] }]] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    
    id application = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[[application stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", returnURLScheme)];
    
    setupBlock(returnURLScheme, client, application);
}

@end

SpecEnd

*/

@end
