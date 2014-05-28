#import "BTClient.h"
#import "BTClient+Testing.h"

void wait_for_potential_async_exceptions(void (^done)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        done();
    });
}

SpecBegin(BTClient_Integration)

__block BTClient *testClient;

beforeEach(^AsyncBlock{
    [BTClient testClientWithConfiguration:@{
                                            BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                            BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                            BTClientTestConfigurationKeyCustomer:@YES,
                                            BTClientTestConfigurationKeyBaseUrl:@"http://example.com/"
                                            } completion:^(BTClient *client) {
                                                testClient = client;
                                                done();
                                            }];
});

describe(@"challenges", ^{
    it(@"returns a set of Gateway specified challenge questions for the merchant", ^AsyncBlock{
        [BTClient testClientWithConfiguration:@{
                                                BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_postal_code_verification_merchant_id",
                                                BTClientTestConfigurationKeyPublicKey:@"client_api_postal_code_verification_public_key",
                                                BTClientTestConfigurationKeyCustomer:@YES }
                                   completion:^(BTClient *client) {
                                       expect(client.challenges).to.contain(@"cvv");
                                       expect(client.challenges).to.contain(@"postal_code");
                                       done();
                                   }];
    });
});

describe(@"save card", ^{
    describe(@"with validation disabled", ^{
        it(@"creates an unlocked card with a nonce using an invalid card", ^AsyncBlock{
            [testClient saveCardWithNumber:@"INVALID_CARD"
                           expirationMonth:@"XX"
                            expirationYear:@"YYYY"
                                       cvv:nil
                                postalCode:nil
                                  validate:NO
                                   success:^(BTPaymentMethod *card) {
                                       expect(card.nonce).to.beANonce();
                                       done();
                                   } failure:nil];
        });

        it(@"creates an unlocked card with a nonce using a valid card", ^AsyncBlock{
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:NO
                                   success:^(BTPaymentMethod *card) {
                                       expect(card.nonce).to.beANonce();
                                       done();
                                   } failure:nil];
        });
    });

    describe(@"with validation enabled", ^{
        it(@"creates an unlocked card with a nonce", ^AsyncBlock{
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:^(BTPaymentMethod *card) {
                                       expect(card.nonce).to.beANonce();
                                       expect(card.locked).to.beFalsy();
                                       done();
                                   } failure:nil];
        });

        it(@"populates card details based on the server-side response", ^AsyncBlock{
            [testClient saveCardWithNumber:@"5555555555554444"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:^(BTCardPaymentMethod *card) {
                                       expect(card.isLocked).to.beFalsy();
                                       expect(card.type).to.equal(BTCardTypeMasterCard);
                                       expect(card.lastTwo).to.equal(@"44");
                                       expect(card.challengeQuestions).to.equal([NSSet setWithObject:@"cvv"]);
                                       expect(card.description).to.equal(@"ending in 44");
                                       done();
                                   } failure:nil];
        });

        it(@"fails when the provided card number is not valid", ^AsyncBlock{
            [testClient saveCardWithNumber:@"4111111111111112"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:nil
                                   failure:^(NSError *error) {
                                       expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                       expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                       done();
                                   }];
        });

        it(@"fails and provides all braintree validation errors when user input is invalid", ^AsyncBlock{
            [testClient saveCardWithNumber:@"4111111111111112"
                           expirationMonth:@"82"
                            expirationYear:@"2"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:nil
                                   failure:^(NSError *error) {
                                       expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).toNot.beNil();

                                       NSDictionary *validationErrors = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey];
                                       NSArray *fieldErrors = validationErrors[@"fieldErrors"];
                                       NSDictionary *creditCardFieldError = fieldErrors[0];

                                       expect(fieldErrors).to.haveCountOf(1);

                                       expect(creditCardFieldError[@"field"]).to.equal(@"creditCard");
                                       expect(creditCardFieldError[@"fieldErrors"]).to.haveCountOf(3);

                                       expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"expirationYear",
                                                                                                  @"message": @"Expiration year is invalid",
                                                                                                  @"code": @"81713"}));
                                       expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"expirationMonth",
                                                                                                  @"message": @"Expiration month is invalid",
                                                                                                  @"code": @"81712"}));
                                       expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"number",
                                                                                                  @"message": @"Credit card number is invalid",
                                                                                                  @"code": @"81715"}));
                                       done();
                                   }];
        });

        it(@"saves a transactable credit card nonce", ^AsyncBlock{
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:^(BTPaymentMethod *card) {
                                       [testClient fetchNonceInfo:card.nonce
                                                          success:^(NSDictionary *nonceInfo) {
                                                              expect(nonceInfo[@"isLocked"]).to.beFalsy();
                                                              expect(nonceInfo[@"isConsumed"]).to.beFalsy();
                                                              done();
                                                          }
                                                          failure:nil];
                                   } failure:nil];
        });

        describe(@"for a merchant with cvv+postal code verification enabled", ^{
            __block BTClient *cvvAndZipClient;
            beforeEach(^AsyncBlock{
                [BTClient testClientWithConfiguration:@{
                                                        BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_postal_code_verification_merchant_id",
                                                        BTClientTestConfigurationKeyPublicKey: @"client_api_postal_code_verification_public_key",
                                                        BTClientTestConfigurationKeyCustomer: @YES }
                                           completion:^(BTClient *client) {
                                               cvvAndZipClient = client;
                                               done();
                                           }];
            });

            it(@"saves a card when the challenges are provided", ^AsyncBlock{
                [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                    expirationMonth:@"12"
                                     expirationYear:@"38"
                                                cvv:@"100"
                                         postalCode:@"15213"
                                           validate:YES
                                            success:^(BTCardPaymentMethod *card) {
                                                expect(card.nonce).to.beANonce();
                                                expect(card.isLocked).to.beFalsy();
                                                done();
                                            } failure:nil];
            });

            pending(@"fails to save a card when the challenges are missing", ^AsyncBlock{
                [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                    expirationMonth:@"12"
                                     expirationYear:@"38"
                                                cvv:nil
                                         postalCode:nil
                                           validate:YES
                                            success:nil
                                            failure:^(NSError *error) {
                                                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.equal(@{});
                                                done();
                                            }];
            });

            pending(@"fails to save a card when a challenge is missing", ^AsyncBlock{
                [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                    expirationMonth:@"12"
                                     expirationYear:@"38"
                                                cvv:@"100"
                                         postalCode:nil
                                           validate:YES
                                            success:nil
                                            failure:^(NSError *error) {
                                                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.equal(@{});
                                                done();
                                            }];
            });

            pending(@"fails to save a card when a challenge response is incorrect", ^AsyncBlock{
                [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                    expirationMonth:@"12"
                                     expirationYear:@"38"
                                                cvv:@"200"
                                         postalCode:@"15213"
                                           validate:YES
                                            success:nil
                                            failure:^(NSError *error) {
                                                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.equal(@{});
                                                done();
                                            }];
            });
        });
    });
});

describe(@"list payment methods", ^{
    __block BTPaymentMethod *card1, *card2;

    beforeEach(^AsyncBlock{
        [testClient saveCardWithNumber:@"4111111111111111"
                       expirationMonth:@"12"
                        expirationYear:@"2018"
                                   cvv:nil
                            postalCode:nil
                              validate:YES
                               success:^(BTPaymentMethod *card) {
                                   card1 = card;
                                   [testClient saveCardWithNumber:@"5555555555554444"
                                                  expirationMonth:@"3"
                                                   expirationYear:@"2016"
                                                              cvv:nil
                                                       postalCode:nil
                                                         validate:YES
                                                          success:^(BTPaymentMethod *card) {
                                                              card2 = card;
                                                              done();
                                                          } failure:nil];
                               } failure:nil];
    });

    it(@"fetches a list of payment methods", ^AsyncBlock{
        [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
            expect(paymentMethods).to.haveCountOf(2);
            [paymentMethods enumerateObjectsUsingBlock:^(BTPaymentMethod *card, NSUInteger idx, BOOL *stop) {
                expect(card.nonce).to.beANonce();
                expect(card.isLocked).to.beFalsy();
            }];
            done();
        } failure:nil];
    });

    it(@"saves two cards and returns them in subsequent calls to list cards", ^AsyncBlock{
        [testClient saveCardWithNumber:@"4111111111111111"
                       expirationMonth:@"12"
                        expirationYear:@"2018"
                                   cvv:nil
                            postalCode:nil
                              validate:YES
                               success:^(BTPaymentMethod *card1){
                                   [testClient saveCardWithNumber:@"5555555555554444"
                                                  expirationMonth:@"3"
                                                   expirationYear:@"2016"
                                                              cvv:nil
                                                       postalCode:nil
                                                         validate:YES
                                                          success:^(BTPaymentMethod *card2){
                                                              [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                                                                  expect(paymentMethods).to.haveCountOf(2);

                                                                  done();
                                                              } failure:nil];
                                                          } failure:nil];
                               } failure:nil];
    });
});

describe(@"get nonce", ^{
    it(@"gets an info dictionary about a nonce", ^AsyncBlock {
        [testClient saveCardWithNumber:@"4111111111111111"
                       expirationMonth:@"12"
                        expirationYear:@"2018"
                                   cvv:nil
                            postalCode:nil
                              validate:YES
                               success:^(BTPaymentMethod *card){
                                   NSString *aNonce = card.nonce;
                                   [testClient fetchNonceInfo:aNonce success:^(NSDictionary *nonceInfo) {
                                       expect(nonceInfo).to.beKindOf([NSDictionary class]);
                                       done();
                                   }
                                                      failure:nil];
                               } failure:nil];
    });

    it(@"fails to get information about a non-existent nonce", ^AsyncBlock {
        [testClient fetchNonceInfo:@"non-existent-nonce" success:nil failure:^(NSError *error) {
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorNonceNotFound);
            done();
        }];
    });

    it(@"fails to get information about a poorly formatted nonce", ^AsyncBlock {
        [testClient fetchNonceInfo:@"?strange/nonce&private_key=foo&stuff%20more" success:nil failure:^(NSError *error) {
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorNonceNotFound);
            done();
        }];
    });
});

describe(@"clients with PayPal activated", ^{
    __block BTClient *testClient;
    beforeEach(^AsyncBlock{
        [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier: @"altpay_merchant",
                                                 BTClientTestConfigurationKeyPublicKey: @"altpay_merchant_public_key",
                                                 BTClientTestConfigurationKeyCustomer: @YES,
                                                 BTClientTestConfigurationKeyBaseUrl: @"http://example.com/" }
                                   completion:^(BTClient *client) {
                                       testClient = client;
                                       done();
                                   }];
    });

    it(@"can save a PayPal payment method based on an auth code", ^AsyncBlock{
        [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode" success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
            expect(payPalPaymentMethod.nonce).to.beANonce();
            expect(payPalPaymentMethod.email).notTo.beNil();
            done();
        } failure:nil];
    });
});

describe(@"a client initialized with a revoked authorization fingerprint", ^{
    __block BTClient *testClient;
    beforeEach(^AsyncBlock{
        [BTClient testClientWithConfiguration:@{
                                                BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                BTClientTestConfigurationKeyCustomer: @YES,
                                                BTClientTestConfigurationKeyBaseUrl: @"http://example.com/",
                                                BTClientTestConfigurationKeyRevoked: @YES,
                                                } completion:^(BTClient *client) {
                                                    testClient = client;
                                                    done();
                                                }];
    });

    it(@"invokes the failure block for list payment methods", ^AsyncBlock{
        [testClient fetchPaymentMethodsWithSuccess:nil failure:^(NSError *error) {
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorUnknown);
            done();
        }];
    });

    it(@"noops for list cards if the failure block is nil", ^AsyncBlock{
        [testClient fetchPaymentMethodsWithSuccess:nil failure:nil];

        wait_for_potential_async_exceptions(done);
    });

    it(@"invokes the failure block for save card", ^AsyncBlock{
        [testClient saveCardWithNumber:@"4111111111111111"
                       expirationMonth:@"12"
                        expirationYear:@"2018"
                                   cvv:nil
                            postalCode:nil
                              validate: NO
                               success:nil
                               failure:^(NSError *error) {
                                   expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                   expect(error.code).to.equal(BTMerchantIntegrationErrorUnknown);
                                   done();
                               }];
    });

    it(@"noops for save card if the failure block is nil", ^AsyncBlock{
        [testClient saveCardWithNumber:@"4111111111111111"
                       expirationMonth:@"12"
                        expirationYear:@"2018"
                                   cvv:nil
                            postalCode:nil
                              validate:YES
                               success:nil
                               failure:nil];
        
        wait_for_potential_async_exceptions(done);
    });
});

SpecEnd