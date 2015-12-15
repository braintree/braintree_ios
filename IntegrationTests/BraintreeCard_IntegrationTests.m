#import "BTIntegrationTestsHelper.h"
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BraintreeCard.h>
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

SpecBegin(BTCardClient_Integration)

describe(@"tokenizeCard:completion:", ^{
    __block BTCardClient *client;

    context(@"with validation disabled", ^{
        beforeEach(^{
            BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
            client = [[BTCardClient alloc] initWithAPIClient:apiClient];
        });

        it(@"creates an unlocked card with a nonce using an invalid card", ^{
            BTCard *card = [[BTCard alloc] init];
            card.number = @"INVALID_CARD";
            card.expirationMonth = @"XX";
            card.expirationYear = @"YYYY";

            XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
            [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenized, NSError * _Nullable error) {
                expect(tokenized.nonce.isANonce).to.beTruthy();
                expect(error).to.beNil();
                [expectation fulfill];
            }];

            [self waitForExpectationsWithTimeout:5 handler:nil];
        });

        it(@"creates an unlocked card with a nonce using a valid card", ^{
            BTCard *card = [[BTCard alloc] init];
            card.number = @"4111111111111111";
            card.expirationMonth = @"12";
            card.expirationYear = @"2018";

            XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
            [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
                expect(tokenizedCard.nonce.isANonce).to.beTruthy();
                expect(error).to.beNil();
                [expectation fulfill];
            }];

            [self waitForExpectationsWithTimeout:5 handler:nil];
        });
    });

    context(@"with validation enabled", ^{
        __block BTCard *card;

        beforeEach(^{
            card = [[BTCard alloc] init];
            card.shouldValidate = YES;
            card.number = @"4111111111111111";
            card.expirationMonth = @"12";
            card.expirationYear = @"2018";
        });

        context(@"and API client uses tokenization key", ^{

            it(@"returns an authorization error", ^{
                client = [[BTCardClient alloc] initWithAPIClient:[[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY]];

                XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
                [client tokenizeCard:card completion:^(BTCardNonce *tokenizedCard, NSError *error) {
                    XCTAssertNil(tokenizedCard);
                    expect(error.domain).to.equal(BTHTTPErrorDomain);
                    expect(error.code).to.equal(BTHTTPErrorCodeClientError);
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)error.userInfo[BTHTTPURLResponseKey];
                    expect(httpResponse.statusCode).to.equal(403);
                    [expectation fulfill];
                }];
                
                [self waitForExpectationsWithTimeout:5 handler:nil];
            });
        });

        context(@"and API client uses client token", ^{
            it(@"returns a tokenized card", ^{
                client = [[BTCardClient alloc] initWithAPIClient:[[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN]];

                XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
                [client tokenizeCard:card completion:^(BTCardNonce *tokenizedCard, NSError *error) {
                    expect(tokenizedCard.nonce.isANonce).to.beTruthy();
                    expect(error).to.beNil();
                    [expectation fulfill];
                }];

                [self waitForExpectationsWithTimeout:5 handler:nil];
            });
        });
    });
});

SpecEnd
