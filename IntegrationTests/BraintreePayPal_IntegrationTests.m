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

@interface BTAppSwitchTestDelegate : NSObject <BTAppSwitchDelegate>
@property (nonatomic, strong) XCTestExpectation *willPerform;
@property (nonatomic, strong) XCTestExpectation *didPerform;
@property (nonatomic, strong) XCTestExpectation *willProcess;
@property (nonatomic, strong) id lastAppSwitcher;
@property (nonatomic, assign) BTAppSwitchTarget lastTarget;
@end

@implementation BTAppSwitchTestDelegate

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

@interface BTViewControllerPresentingTestDelegate : NSObject <BTViewControllerPresentingDelegate>
@property (nonatomic, strong) XCTestExpectation *requestsPresentationExpectation;
@property (nonatomic, strong) XCTestExpectation *requestsDismissalExpectation;
@property (nonatomic, strong) id lastDriver;
@property (nonatomic, strong) id lastViewController;
@end

@implementation BTViewControllerPresentingTestDelegate

- (void)paymentDriver:(id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    self.lastDriver = driver;
    self.lastViewController = viewController;
    [self.requestsDismissalExpectation fulfill];
}

- (void)paymentDriver:(id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    self.lastDriver = driver;
    self.lastViewController = viewController;
    [self.requestsPresentationExpectation fulfill];
}

@end


@interface BraintreePayPal_IntegrationTests : XCTestCase
@property (nonatomic, strong) NSNumber *didReceiveCompletionCallback;
@end


@implementation BraintreePayPal_IntegrationTests

NSString * const OneTouchCoreAppSwitchSuccessURLFixture = @"com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoyLCJhY2NvdW50X2NvdW50cnkiOiJVUyIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXhwaXJlc19pbiI6LTEsImRpc3BsYXlfbmFtZSI6Im1vY2tEaXNwbGF5TmFtZSIsInNjb3BlIjoiaHR0cHM6XC9cL3VyaS5wYXlwYWwuY29tXC9zZXJ2aWNlc1wvcGF5bWVudHNcL2Z1dHVyZXBheW1lbnRzIiwiZW1haWwiOiJtb2NrZW1haWxhZGRyZXNzQG1vY2suY29tIiwiYXV0aG9yaXphdGlvbl9jb2RlIjoibW9ja1RoaXJkUGFydHlBdXRob3JpemF0aW9uQ29kZSJ9&x-source=com.paypal.ppclient.touch.v1-or-v2";

#pragma mark - Authorization (Future Payments)

- (void)testFuturePayments_tokenizesPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    payPalDriver.clientMetadataId = @"fake-client-metadata-id";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenized PayPal Account"];
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
        [expectation fulfill];
    }];

    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture]];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_whenPayPalIsNotEnabledInControlPanel_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration2_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeDisabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFuturePayments_whenReturnURLSchemeIsMissing_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeIntegrationReturnURLScheme);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}


- (void)testFuturePayments_whenReturnURLSchemeIsInvalid_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"not-my-app-bundle-id";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertEqualObjects(error.domain, BTPayPalDriverErrorDomain);
        XCTAssertEqual(error.code, BTPayPalDriverErrorTypeIntegrationReturnURLScheme);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// FIXME: Revisit this when Braintree browser switch supports tokenization key
- (void)pendFuturePayments_onSuccessfulBrowserSwitchAuthorization_returnsTokenizedPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([mockApplication canOpenURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andReturn(YES);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Browser switch occurred"];
    OCMStub([mockApplication openURL:OCMArgCheckURLSchemeBeginsWith(@"https")]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    self.didReceiveCompletionCallback = nil;
    
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertTrue(tokenizedPayPalAccount.nonce.isANonce);
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
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNil(tokenizedPayPalAccount);
        XCTAssertNil(error);
        self.didReceiveCompletionCallback = @(YES);
    }];

    [BTPayPalDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.braintreepayments.Demo.payments://onetouch/v1/cancel?payload=eyJ2ZXJzaW9uIjozLCJtc2dfR1VJRCI6IjQ1QUZEQkE3LUJEQTYtNDNEMi04MUY2LUY4REM1QjZEOTkzQSIsImVudmlyb25tZW50IjoibW9jayJ9&x-source=com.paypal.ppclient.touch.v2"]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Analytics

// MARK: Analytics

- (void)testAnalytics_whenInitiatingFuturePayments_postsExpectedEventBeforePerformingAppSwitch {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];


    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    // BTPayPalDriver copies APIClient, so we have to mock the API client after the call to initWithAPIClient
    id partialMockAPIClient = OCMPartialMock(payPalDriver.apiClient);
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }

    OCMStub([mockApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        XCTAssertNil(error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    if (NSClassFromString(@"SFSafariViewController")) {
        OCMVerify([partialMockAPIClient sendAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"]);
    } else {
        OCMVerify([partialMockAPIClient sendAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.started"]);
    }
}

#pragma mark - Return URL handling

- (void)testCanHandleAppSwitchReturnURL_forURLsFromBrowserSwitch_returnsYES {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }

    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
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

- (void)testCanHandleAppSwitchReturnURL_forURLsFromWebSwitch_returnsYES {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    BOOL canHandleV1AppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.apple.mobilesafari"];
    BOOL canHandleV2AppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.apple.safariviewservice"];

    XCTAssertTrue(canHandleV1AppSwitch);
    XCTAssertTrue(canHandleV2AppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_forMalformedURLs_returnsNO {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
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

- (void)testCanHandleAppSwitchReturnURL_forUnsupportedSourceApplication_returnsNO {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);
    
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    // This malformed returnURL is just missing payload
    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.example.application"];
    
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
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        XCTAssertNotNil(tokenizedPayPalAccount);
        if (error) {
            XCTFail(@"%@", error);
        }
        self.didReceiveCompletionCallback = @(YES);
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    BOOL canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.apple.mobilesafari"];
    XCTAssertTrue(canHandleAppSwitch);
    [BTPayPalDriver handleAppSwitchReturnURL:returnURL];

    // Pause until handleAppSwitchReturnURL has finished
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];

    canHandleAppSwitch = [BTPayPalDriver canHandleAppSwitchReturnURL:returnURL sourceApplication:@"com.apple.mobilesafari"];
    XCTAssertFalse(canHandleAppSwitch);
}

- (void)testCanHandleAppSwitchReturnURL_whenAppSwitchReturnURLHasMismatchedCase_returnsYES {
    // Motivation for this test is because of Safari's habit of downcasing URL schemes
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }

    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
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
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
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
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";
    BTViewControllerPresentingTestDelegate *viewControllerPresentingDelegate = [[BTViewControllerPresentingTestDelegate alloc] init];
    BTAppSwitchTestDelegate *appSwitchDelegate = [[BTAppSwitchTestDelegate alloc] init];
    if (NSClassFromString(@"SFSafariViewController")) {
        viewControllerPresentingDelegate.requestsPresentationExpectation = [self expectationWithDescription:@"Delegate received requestsPresentation"];
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate;
    } else {
        appSwitchDelegate.willPerform = [self expectationWithDescription:@"Delegate received willPerformAppSwitch"];
        appSwitchDelegate.didPerform = [self expectationWithDescription:@"Delegate received didPerformAppSwitch"];
        payPalDriver.appSwitchDelegate = appSwitchDelegate;
    }
    id stubApplication = OCMPartialMock([UIApplication sharedApplication]);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);

    self.didReceiveCompletionCallback = nil;
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
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

@end
