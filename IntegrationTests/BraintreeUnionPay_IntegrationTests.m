#import "BTNonceValidationHelper.h"
#import "IntegrationTests-Swift.h"
#import <BraintreeUnionPay/BraintreeUnionPay.h>
#import <XCTest/XCTest.h>

@interface BraintreeUnionPay_IntegrationTests : XCTestCase
@property (nonatomic, strong) BTCardClient *cardClient;
@end

@implementation BraintreeUnionPay_IntegrationTests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)setUp {
    [super setUp];

    static NSString *clientToken;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clientToken = [self fetchClientToken];
    });

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
    self.cardClient = [[BTCardClient alloc] initWithAPIClient:apiClient];
}

- (void)pendFetchCapabilities_returnsCardCapabilities {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.cardClient fetchCapabilities:@"6212345678901232" completion:^(BTCardCapabilities * _Nullable cardCapabilities, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertFalse(cardCapabilities.isDebit);
        XCTAssertTrue(cardCapabilities.isUnionPay);
        XCTAssertTrue(cardCapabilities.isSupported);
        XCTAssertTrue(cardCapabilities.supportsTwoStepAuthAndCapture);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)pendEnrollCard_whenSuccessful_returnsEnrollmentID {
    BTCard *card = [BTCard new];
    card.number = @"6222821234560017";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    card.cvv = @"123";

    BTCardRequest *request = [[BTCardRequest alloc] init];
    request.card = card;
    request.mobileCountryCode = @"62";
    request.mobilePhoneNumber = @"12345678901";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.cardClient enrollCard:request completion:^(NSString * _Nullable enrollmentID, __unused BOOL smsCodeRequired, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([enrollmentID isKindOfClass:[NSString class]]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)pendEnrollCard_whenCardDoesNotRequireEnrollment_returnsError {
    BTCard *card = [BTCard new];
    card.number = @"6212345678900085";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    card.cvv = @"123";

    BTCardRequest *request = [[BTCardRequest alloc] init];
    request.card = card;
    request.mobileCountryCode = @"62";
    request.mobilePhoneNumber = @"12345678901";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.cardClient enrollCard:request completion:^(NSString * _Nullable enrollmentID, __unused BOOL smsCodeRequired, NSError * _Nullable error) {
        XCTAssertNil(enrollmentID);
        XCTAssertEqualObjects(error.domain, BTCardClientErrorDomain);
        XCTAssertEqual(error.code, BTCardClientErrorTypeCustomerInputInvalid);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)pendTokenizeCard_withEnrolledUnionPayCard_isSuccessful {
    BTCard *card = [BTCard new];
    card.number = @"6212345678901232";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    card.cvv = @"123";

    BTCardRequest *request = [[BTCardRequest alloc] init];
    request.card = card;
    request.mobileCountryCode = @"62";
    request.mobilePhoneNumber = @"12345678901";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.cardClient enrollCard:request completion:^(NSString * _Nullable enrollmentID, __unused BOOL smsCodeRequired, NSError * _Nullable error) {
        XCTAssertNil(error);
        request.enrollmentID = enrollmentID;
        request.smsCode = @"11111";
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.cardClient tokenizeCard:request options:nil completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([tokenizedCard.nonce isANonce]);
        XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetworkUnionPay);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Helpers

- (NSString *)fetchClientToken {
    NSURL *url = [NSURL URLWithString:@"http://braintree-sample-merchant.herokuapp.com/client_token?merchant_account_id=fake_switch_usd"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return jsonResponse[@"client_token"];
}
#pragma clang diagnostic pop

@end
