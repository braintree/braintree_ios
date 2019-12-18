#import "BTNonceValidationHelper.h"
#import "IntegrationTests-Swift.h"
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BraintreeCard.h>
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

@interface BTCardClient_IntegrationTests : XCTestCase
@end

@implementation BTCardClient_IntegrationTests

- (void)testTokenizeCard_whenCardHasValidationDisabledAndCardIsInvalid_tokenizesSuccessfully {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self invalidCard];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        expect(tokenizedCard.threeDSecureInfo.wasVerified).to.beFalsy();
        expect(error).to.beNil();
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeCard_whenCardIsInvalidAndValidationIsEnabled_failsWithExpectedValidationError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [[BTCard alloc] initWithNumber:@"123" expirationMonth:@"12" expirationYear:Helpers.sharedInstance.futureYear cvv:nil];
    card.shouldValidate = YES;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertNil(tokenizedCard);
        XCTAssertEqualObjects(error.domain, BTCardClientErrorDomain);
        XCTAssertEqual(error.code, BTCardClientErrorTypeCustomerInputInvalid);
        XCTAssertEqualObjects(error.localizedDescription, @"Input is invalid");
        XCTAssertEqualObjects(error.localizedFailureReason, @"Credit card number must be 12-19 digits");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeCard_whenCardHasValidationDisabledAndCardIsValid_tokenizesSuccessfully {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self validCard];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        expect(tokenizedCard.binData.prepaid).toNot.beNil();
        expect(tokenizedCard.binData.healthcare).toNot.beNil();
        expect(tokenizedCard.binData.debit).toNot.beNil();
        expect(tokenizedCard.binData.durbinRegulated).toNot.beNil();
        expect(tokenizedCard.binData.commercial).toNot.beNil();
        expect(tokenizedCard.binData.payroll).toNot.beNil();
        expect(tokenizedCard.binData.issuingBank).toNot.beNil();
        expect(tokenizedCard.binData.countryOfIssuance).toNot.beNil();
        expect(tokenizedCard.binData.productId).toNot.beNil();
        expect(tokenizedCard.threeDSecureInfo.liabilityShiftPossible).to.beFalsy();
        expect(tokenizedCard.threeDSecureInfo.liabilityShifted).to.beFalsy();
        expect(tokenizedCard.threeDSecureInfo.wasVerified).to.beFalsy();
        expect(error).to.beNil();
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}


- (void)testTokenizeCard_whenUsingTokenizationKeyAndCardHasValidationEnabled_failsWithAuthorizationError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self invalidCard];
    card.shouldValidate = YES;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertNil(tokenizedCard);
        expect(error.domain).to.equal(BTHTTPErrorDomain);
        expect(error.code).to.equal(BTHTTPErrorCodeClientError);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)error.userInfo[BTHTTPURLResponseKey];
        expect(httpResponse.statusCode).to.equal(403);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeCard_whenUsingClientTokenAndCardHasValidationEnabledAndCardIsValid_tokenizesSuccessfully {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self validCard];
    card.shouldValidate = YES;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        expect(tokenizedCard.threeDSecureInfo.wasVerified).to.beFalsy();
        expect(error).to.beNil();
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeCard_whenUsingVersionThreeClientTokenAndCardHasValidationEnabledAndCardIsValid_tokenizesSuccessfully {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN_VERSION_3];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self validCard];
    card.shouldValidate = YES;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        expect(tokenizedCard.threeDSecureInfo.wasVerified).to.beFalsy();
        expect(error).to.beNil();
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeCard_withCVVOnly_tokenizesSuccessfully {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN_VERSION_3];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [[BTCard alloc] init];
    card.cvv = @"123";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        expect(error).to.beNil();
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Helpers

- (BTCard *)invalidCard {
    BTCard *card = [[BTCard alloc] init];
    card.number = @"123123";
    card.expirationMonth = @"XX";
    card.expirationYear = @"XXXX";
    return card;
}

- (BTCard *)validCard {
    BTCard *card = [[BTCard alloc] init];
    card.number = @"4111111111111111";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    return card;
}

@end
