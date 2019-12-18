#import "BTNonceValidationHelper.h"
#import "IntegrationTests-Swift.h"
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeAmericanExpress/BraintreeAmericanExpress.h>
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

@interface BTAmericanExpressClient_IntegrationTests : XCTestCase
@end

@implementation BTAmericanExpressClient_IntegrationTests

- (void)testGetRewardsBalance_whenCardIsValid_returnsPayload_withRewardsBalance {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN_VERSION_3];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTAmericanExpressClient *amexClient = [[BTAmericanExpressClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self successCard];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Get rewards"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(error).to.beNil();
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        NSString *nonce = tokenizedCard.nonce;
        [amexClient getRewardsBalanceForNonce:nonce currencyIsoCode:@"USD" completion:^(BTAmericanExpressRewardsBalance * _Nullable payload, NSError * _Nullable error) {
            expect(error).to.beNil();
            expect(payload.conversionRate).toNot.beNil();
            expect(payload.currencyAmount).toNot.beNil();
            expect(payload.currencyIsoCode).toNot.beNil();
            expect(payload.requestId).toNot.beNil();
            expect(payload.rewardsAmount).toNot.beNil();
            expect(payload.rewardsUnit).toNot.beNil();
            expect(payload.errorCode).to.beNil();
            expect(payload.errorMessage).to.beNil();
            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGetRewardsBalance_whenCardHasInsufficientPoints_returnsPayload_withError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN_VERSION_3];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTAmericanExpressClient *amexClient = [[BTAmericanExpressClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self insufficientPointsCard];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Get rewards"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(error).to.beNil();
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        NSString *nonce = tokenizedCard.nonce;
        [amexClient getRewardsBalanceForNonce:nonce currencyIsoCode:@"USD" completion:^(BTAmericanExpressRewardsBalance * _Nullable payload, NSError * _Nullable error) {
            expect(error).to.beNil();
            expect(payload.conversionRate).to.beNil();
            expect(payload.currencyAmount).to.beNil();
            expect(payload.currencyIsoCode).to.beNil();
            expect(payload.requestId).to.beNil();
            expect(payload.rewardsAmount).to.beNil();
            expect(payload.rewardsUnit).to.beNil();
            expect(payload.errorCode).to.match(@"INQ2003");
            expect(payload.errorMessage).toNot.beNil();
            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGetRewardsBalance_whenCardIsIneligible_returnsPayload_withError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN_VERSION_3];
    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
    BTAmericanExpressClient *amexClient = [[BTAmericanExpressClient alloc] initWithAPIClient:apiClient];
    BTCard *card = [self ineligibleCard];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Get rewards"];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        expect(error).to.beNil();
        expect(tokenizedCard.nonce.isANonce).to.beTruthy();
        NSString *nonce = tokenizedCard.nonce;
        [amexClient getRewardsBalanceForNonce:nonce currencyIsoCode:@"USD" completion:^(BTAmericanExpressRewardsBalance * _Nullable payload, NSError * _Nullable error) {
            expect(error).to.beNil();
            expect(payload.conversionRate).to.beNil();
            expect(payload.currencyAmount).to.beNil();
            expect(payload.currencyIsoCode).to.beNil();
            expect(payload.requestId).to.beNil();
            expect(payload.rewardsAmount).to.beNil();
            expect(payload.rewardsUnit).to.beNil();
            expect(payload.errorCode).to.match(@"INQ2002");
            expect(payload.errorMessage).toNot.beNil();
            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Helpers

- (BTCard *)successCard {
    BTCard *card = [[BTCard alloc] init];
    card.number = @"371260714673002";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    return card;
}

- (BTCard *)insufficientPointsCard {
    BTCard *card = [[BTCard alloc] init];
    card.number = @"371544868764018";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    return card;
}

- (BTCard *)ineligibleCard {
    BTCard *card = [[BTCard alloc] init];
    card.number = @"378267515471109";
    card.expirationMonth = @"12";
    card.expirationYear = Helpers.sharedInstance.futureYear;
    return card;
}

@end
