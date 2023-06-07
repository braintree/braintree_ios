#import "BTNonceValidationHelper.h"
#import "IntegrationTests-Swift.h"
#import <XCTest/XCTest.h>

@import BraintreeCore;
@import BraintreeCard;

@interface BTCardClient_IntegrationTests : XCTestCase
@end

@implementation BTCardClient_IntegrationTests

- (void)testTokenizeCard_whenCardHasValidationDisabledAndCardIsInvalid_tokenizesSuccessfully {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self invalidCard];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedCard.nonce.isANonce);
        XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeCard_whenCardIsInvalidAndValidationIsEnabled_failsWithExpectedValidationError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    
    BTCard *card = [BTCard new];
    card.number = @"123";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    card.shouldValidate = YES;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertNil(tokenizedCard);
        XCTAssertEqualObjects(error.domain, @"com.braintreepayments.BTCardClientErrorDomain");
        XCTAssertEqual(error.code, 2);
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
        XCTAssertTrue(tokenizedCard.nonce.isANonce);
        XCTAssertNotNil(tokenizedCard.expirationMonth);
        XCTAssertNotNil(tokenizedCard.expirationYear);
        XCTAssertNotNil(tokenizedCard.cardholderName);
        XCTAssertNotNil(tokenizedCard.binData.prepaid);
        XCTAssertNotNil(tokenizedCard.binData.healthcare);
        XCTAssertNotNil(tokenizedCard.binData.debit);
        XCTAssertNotNil(tokenizedCard.binData.durbinRegulated);
        XCTAssertNotNil(tokenizedCard.binData.commercial);
        XCTAssertNotNil(tokenizedCard.binData.payroll);
        XCTAssertNotNil(tokenizedCard.binData.issuingBank);
        XCTAssertNotNil(tokenizedCard.binData.countryOfIssuance);
        XCTAssertNotNil(tokenizedCard.binData.productID);
        XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShiftPossible);
        XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShifted);
        XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified);
        XCTAssertNil(error);
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
        XCTAssertEqualObjects(error.domain, BTCoreConstants.httpErrorDomain);
        XCTAssertEqual(error.code, 2);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)error.userInfo[BTCoreConstants.urlResponseKey];
        XCTAssertEqual(httpResponse.statusCode, 403);
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
        XCTAssertTrue(tokenizedCard.nonce.isANonce);
        XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified);
        XCTAssertNil(error);
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
        XCTAssertTrue(tokenizedCard.nonce.isANonce);
        XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified);
        XCTAssertNil(error);
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
        XCTAssertTrue(tokenizedCard.nonce.isANonce);
        XCTAssertNil(error);
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
    card.cardholderName = @"Alyssa Edwards";
    return card;
}

@end
