#import "BTClient_Internal.h"
#import "BTClient+Testing.h"
#import "BTSpecHelper.h"
#import "BTCardPaymentMethod_Mutable.h"

@import AddressBook;

SharedExamplesBegin(BTClient_Integration)

sharedExamplesFor(@"a BTClient", ^(NSDictionary *data) {

  __block BTClient *testClient;
  __block BOOL asyncClient = [data[@"asyncClient"] boolValue];

  beforeEach(^{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Load test client token"];
    [BTClient testClientWithConfiguration:@{
                                            BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                            BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                            BTClientTestConfigurationKeyCustomer:@YES,
                                            BTClientTestConfigurationKeyClientTokenVersion: @2
                                            }
                                            async:asyncClient
                                            completion:^(BTClient *client) {
                                              testClient = client;
                                              [expectation fulfill];
                                            }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
  });

  describe(@"challenges", ^{
      it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch test client"];
          [BTClient testClientWithConfiguration:@{
                                                  BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                  BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                  BTClientTestConfigurationKeyCustomer:@YES }
                                          async:asyncClient completion:^(BTClient *client) {
                                         expect(client.challenges).to.haveCountOf(0);
                                         [expectation fulfill];
                                     }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
      it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch test client"];
          [BTClient testClientWithConfiguration:@{
                                                  BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_cvv_verification_merchant_id",
                                                  BTClientTestConfigurationKeyPublicKey:@"client_api_cvv_verification_public_key",
                                                  BTClientTestConfigurationKeyCustomer:@YES }
                                     async:asyncClient completion:^(BTClient *client) {
                                         expect(client.challenges).to.haveCountOf(1);
                                         expect(client.challenges).to.contain(@"cvv");
                                         [expectation fulfill];
                                     }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
      it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch test client"];
          [BTClient testClientWithConfiguration:@{
                                                  BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_postal_code_verification_merchant_id",
                                                  BTClientTestConfigurationKeyPublicKey:@"client_api_postal_code_verification_public_key",
                                                  BTClientTestConfigurationKeyCustomer:@YES }
                                     async:asyncClient completion:^(BTClient *client) {
                                         expect(client.challenges).to.haveCountOf(1);
                                         expect(client.challenges).to.contain(@"postal_code");
                                         [expectation fulfill];
                                     }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
      it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch test client"];
          [BTClient testClientWithConfiguration:@{
                                                  BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_cvv_and_postal_code_verification_merchant_id",
                                                  BTClientTestConfigurationKeyPublicKey:@"client_api_cvv_and_postal_code_verification_public_key",
                                                  BTClientTestConfigurationKeyCustomer:@YES }
                                     async:asyncClient completion:^(BTClient *client) {
                                         expect(client.challenges).to.haveCountOf(2);
                                         expect(client.challenges).to.contain(@"postal_code");
                                         expect(client.challenges).to.contain(@"cvv");
                                         [expectation fulfill];
                                     }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"save card with request", ^{
      describe(@"with validation disabled", ^{
          it(@"creates an unlocked card with a nonce using an invalid card", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"INVALID_CARD";
              request.expirationMonth = @"XX";
              request.expirationYear = @"YYYY";
              [testClient saveCardWithRequest:request
                                      success:^(BTPaymentMethod *card) {
                                          expect(card.nonce).to.beANonce();
                                          [expectation fulfill];
                                      } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"creates an unlocked card with a nonce using a valid card", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111111";
              request.expirationMonth = @"12";
              request.expirationYear = @"2018";
              [testClient saveCardWithRequest:request
                                      success:^(BTPaymentMethod *card) {
                                          expect(card.nonce).to.beANonce();
                                          [expectation fulfill];
                                      } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"with validation enabled", ^{
          it(@"creates an unlocked card with a nonce", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111111";
              request.expirationMonth = @"12";
              request.expirationYear = @"2018";
              request.shouldValidate = YES;
              [testClient saveCardWithRequest:request
                                      success:^(BTPaymentMethod *card) {
                                          expect(card.nonce).to.beANonce();
                                          [expectation fulfill];
                                      } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"populates card details based on the server-side response", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];

              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"5555555555554444";
              request.expirationDate = @"12/2018";
              request.shouldValidate = YES;
              [testClient saveCardWithRequest:request
                                      success:^(BTCardPaymentMethod *card) {
                                          expect(card.type).to.equal(BTCardTypeMasterCard);
                                          expect(card.lastTwo).to.equal(@"44");
                                          expect(card.description).to.equal(@"ending in 44");
                                          [expectation fulfill];
                                      } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails when the provided card number is not valid", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111112";
              request.expirationMonth = @"12";
              request.expirationYear = @"2018";
              request.shouldValidate = YES;
              [testClient saveCardWithRequest:request
                                      success:nil
                                      failure:^(NSError *error) {
                                          expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                          expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                          [expectation fulfill];
                                      }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails and provides all braintree validation errors when user input is invalid", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111112";
              request.expirationMonth = @"82";
              request.expirationYear = @"2";
              request.shouldValidate = YES;

              [testClient saveCardWithRequest:request
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
                                          [expectation fulfill];
                                      }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"saves a transactable credit card nonce", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111111";
              request.expirationMonth = @"12";
              request.expirationYear = @"2018";
              request.shouldValidate = YES;

              [testClient saveCardWithRequest:request
                                      success:^(BTPaymentMethod *card) {
                                          [testClient fetchNonceInfo:card.nonce
                                                             success:^(NSDictionary *nonceInfo) {
                                                                 expect(nonceInfo[@"isLocked"]).to.beFalsy();
                                                                 expect(nonceInfo[@"isConsumed"]).to.beFalsy();
                                                                 [expectation fulfill];
                                                             }
                                                             failure:nil];
                                      } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"for a merchant with payment method verification enabled", ^{
          __block BTClient *cvvAndZipClient;
          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client"];
              [BTClient testClientWithConfiguration:@{
                                                      BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_cvv_and_postal_code_verification_merchant_id",
                                                      BTClientTestConfigurationKeyPublicKey: @"client_api_cvv_and_postal_code_verification_public_key",
                                                      BTClientTestConfigurationKeyCustomer: @YES }
                                         async:asyncClient completion:^(BTClient *client) {
                                             cvvAndZipClient = client;
                                             [expectation fulfill];
                                         }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"saves a card when the challenges are provided", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111111";
              request.expirationMonth = @"12";
              request.expirationYear = @"38";
              request.cvv = @"100";
              request.postalCode = @"15213";
              request.shouldValidate = YES;
              [cvvAndZipClient saveCardWithRequest:request
                                           success:^(BTCardPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();
                                               [expectation fulfill];
                                           } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails to save a card when a cvv response is incorrect", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
              [BTClient testClientWithConfiguration:@{
                                                      BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_cvv_verification_merchant_id",
                                                      BTClientTestConfigurationKeyPublicKey: @"client_api_cvv_verification_public_key",
                                                      BTClientTestConfigurationKeyCustomer: @YES }
                                         async:asyncClient completion:^(BTClient *cvvClient) {
                                             BTClientCardRequest *request = [[BTClientCardRequest alloc] init];

                                             request.number = @"4111111111111111";
                                             request.expirationMonth = @"12";
                                             request.expirationYear = @"38";
                                             request.cvv = @"200";
                                             request.postalCode = @"15213";
                                             request.shouldValidate = YES;
                                             [cvvClient saveCardWithRequest:request
                                                                    success:nil
                                                                    failure:^(NSError *error) {
                                                                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                        expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                        expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                                                                        expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                                                                        [expectation fulfill];
                                                                    }];
                                         }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails to save a card when a postal code response is incorrect", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              [BTClient testClientWithConfiguration:@{
                                                      BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_postal_code_verification_merchant_id",
                                                      BTClientTestConfigurationKeyPublicKey: @"client_api_postal_code_verification_public_key",
                                                      BTClientTestConfigurationKeyCustomer: @YES }
                                         async:asyncClient completion:^(BTClient *zipClient) {
                                             request.number = @"4111111111111111";
                                             request.expirationMonth = @"12";
                                             request.expirationYear = @"38";
                                             request.cvv = @"100";
                                             request.postalCode = @"20000";
                                             request.shouldValidate = YES;
                                             [zipClient saveCardWithRequest:request
                                                                    success:nil
                                                                    failure:^(NSError *error) {
                                                                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                        expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                        expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                                                                        expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");

                                                                        [expectation fulfill];
                                                                    }];
                                         }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails to save a card when cvv and postal code responses are both incorrect", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
              BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
              request.number = @"4111111111111111";
              request.expirationMonth = @"12";
              request.expirationYear = @"38";
              request.cvv = @"200";
              request.postalCode = @"20000";
              request.shouldValidate = YES;
              [cvvAndZipClient saveCardWithRequest:request
                                           success:nil
                                           failure:^(NSError *error) {
                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(2);
                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][1][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");
                                               [expectation fulfill];
                                           }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });
  });


  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wdeprecated-declarations"
  describe(@"save card (deprecated signature)", ^{
      describe(@"with validation disabled", ^{
          it(@"creates an unlocked card with a nonce using an invalid card", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              [testClient saveCardWithNumber:@"INVALID_CARD"
                             expirationMonth:@"XX"
                              expirationYear:@"YYYY"
                                         cvv:nil
                                  postalCode:nil
                                    validate:NO
                                     success:^(BTPaymentMethod *card) {
                                         expect(card.nonce).to.beANonce();
                                         [expectation fulfill];
                                     } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"creates an unlocked card with a nonce using a valid card", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              [testClient saveCardWithNumber:@"4111111111111111"
                             expirationMonth:@"12"
                              expirationYear:@"2018"
                                         cvv:nil
                                  postalCode:nil
                                    validate:NO
                                     success:^(BTPaymentMethod *card) {
                                         expect(card.nonce).to.beANonce();
                                         [expectation fulfill];
                                     } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"with validation enabled", ^{
          it(@"creates an unlocked card with a nonce", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              [testClient saveCardWithNumber:@"4111111111111111"
                             expirationMonth:@"12"
                              expirationYear:@"2018"
                                         cvv:nil
                                  postalCode:nil
                                    validate:YES
                                     success:^(BTPaymentMethod *card) {
                                         expect(card.nonce).to.beANonce();
                                         [expectation fulfill];
                                     } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"populates card details based on the server-side response", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              [testClient saveCardWithNumber:@"5555555555554444"
                             expirationMonth:@"12"
                              expirationYear:@"2018"
                                         cvv:nil
                                  postalCode:nil
                                    validate:YES
                                     success:^(BTCardPaymentMethod *card) {
                                         expect(card.type).to.equal(BTCardTypeMasterCard);
                                         expect(card.lastTwo).to.equal(@"44");
                                         expect(card.description).to.equal(@"ending in 44");
                                         [expectation fulfill];
                                     } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails when the provided card number is not valid", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
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
                                         [expectation fulfill];
                                     }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails and provides all braintree validation errors when user input is invalid", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
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
                                         [expectation fulfill];
                                     }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"saves a transactable credit card nonce", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
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
                                                                [expectation fulfill];
                                                            }
                                                            failure:nil];
                                     } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          describe(@"for a merchant with payment method verification enabled", ^{
              __block BTClient *cvvAndZipClient;
              beforeEach(^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
                  [BTClient testClientWithConfiguration:@{
                                                          BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_cvv_and_postal_code_verification_merchant_id",
                                                          BTClientTestConfigurationKeyPublicKey: @"client_api_cvv_and_postal_code_verification_public_key",
                                                          BTClientTestConfigurationKeyCustomer: @YES }
                                             async:asyncClient completion:^(BTClient *client) {
                                                 cvvAndZipClient = client;
                                                 [expectation fulfill];
                                             }];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });

              it(@"saves a card when the challenges are provided", ^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
                  [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                      expirationMonth:@"12"
                                       expirationYear:@"38"
                                                  cvv:@"100"
                                           postalCode:@"15213"
                                             validate:YES
                                              success:^(BTCardPaymentMethod *card) {
                                                  expect(card.nonce).to.beANonce();
                                                  [expectation fulfill];
                                              } failure:nil];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });

              it(@"fails to save a card when a cvv response is incorrect", ^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
                  [BTClient testClientWithConfiguration:@{
                                                          BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_cvv_verification_merchant_id",
                                                          BTClientTestConfigurationKeyPublicKey: @"client_api_cvv_verification_public_key",
                                                          BTClientTestConfigurationKeyCustomer: @YES }
                                             async:asyncClient completion:^(BTClient *cvvClient) {

                                                 [cvvClient saveCardWithNumber:@"4111111111111111"
                                                               expirationMonth:@"12"
                                                                expirationYear:@"38"
                                                                           cvv:@"200"
                                                                    postalCode:@"15213"
                                                                      validate:YES
                                                                       success:nil
                                                                       failure:^(NSError *error) {
                                                                           expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                           expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                           expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                                                                           expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                                                                           [expectation fulfill];
                                                                       }];
                                             }];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });

              it(@"fails to save a card when a postal code response is incorrect", ^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
                  [BTClient testClientWithConfiguration:@{
                                                          BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_postal_code_verification_merchant_id",
                                                          BTClientTestConfigurationKeyPublicKey: @"client_api_postal_code_verification_public_key",
                                                          BTClientTestConfigurationKeyCustomer: @YES }
                                             async:asyncClient completion:^(BTClient *zipClient) {
                                                 [zipClient saveCardWithNumber:@"4111111111111111"
                                                               expirationMonth:@"12"
                                                                expirationYear:@"38"
                                                                           cvv:@"100"
                                                                    postalCode:@"20000"
                                                                      validate:YES
                                                                       success:nil
                                                                       failure:^(NSError *error) {
                                                                           expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                           expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                           expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                                                                           expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");

                                                                           [expectation fulfill];
                                                                       }];
                                             }];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });

              it(@"fails to save a card when cvv and postal code responses are both incorrect", ^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
                  [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                      expirationMonth:@"12"
                                       expirationYear:@"38"
                                                  cvv:@"200"
                                           postalCode:@"20000"
                                             validate:YES
                                              success:nil
                                              failure:^(NSError *error) {
                                                  expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                  expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                  expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(2);
                                                  expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                                                  expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][1][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");
                                                  [expectation fulfill];
                                              }];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });
          });
      });
  });
  #pragma clang diagnostic pop

  describe(@"list payment methods", ^{
      __block BTPaymentMethod *card1, *card2;

      beforeEach(^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save cards"];
          BTClientCardRequest *request1 = [[BTClientCardRequest alloc] init];
          request1.number = @"4111111111111111";
          request1.expirationMonth = @"12";
          request1.expirationYear = @"2018";
          request1.shouldValidate = YES;

          [testClient saveCardWithRequest:request1
                                  success:^(BTPaymentMethod *card) {
                                      card1 = card;
                                      BTClientCardRequest *request2 = [[BTClientCardRequest alloc] init];

                                      request2.number = @"5555555555554444";
                                      request2.expirationDate = @"03/2016";
                                      request2.shouldValidate = YES;

                                      [testClient saveCardWithRequest:request2
                                                              success:^(BTPaymentMethod *card) {
                                                                  card2 = card;
                                                                  [expectation fulfill];
                                                              } failure:nil];
                                  } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"fetches a list of payment methods", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch payment methods"];
          [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
              expect(paymentMethods).to.haveCountOf(2);
              expect([paymentMethods[0] nonce]).to.beANonce();
              expect([paymentMethods[1] nonce]).to.beANonce();
              [expectation fulfill];
          } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"saves two cards and returns them in subsequent calls to list cards", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save two cards"];
          BTClientCardRequest *request1 = [[BTClientCardRequest alloc] init];
          request1.number = @"4111111111111111";
          request1.expirationMonth = @"12";
          request1.expirationYear = @"2018";
          request1.shouldValidate = YES;

          [testClient saveCardWithRequest:request1
                                  success:^(BTPaymentMethod *card1){
                                      BTClientCardRequest *request2 = [[BTClientCardRequest alloc] init];
                                      request2.number = @"5555555555554444";
                                      request2.expirationMonth = @"3";
                                      request2.expirationYear = @"2016";
                                      request2.shouldValidate = YES;

                                      [testClient saveCardWithRequest:request2
                                                              success:^(BTPaymentMethod *card2){
                                                                  [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                                                                      expect(paymentMethods).to.haveCountOf(2);

                                                                      [expectation fulfill];
                                                                  } failure:nil];
                                                              } failure:nil];
                                  } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"show payment method", ^{
      it(@"gets a full representation of a payment method based on a nonce", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save and fetch payment method"];
          BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
          request.number = @"4111111111111111";
          request.expirationMonth = @"12";
          request.expirationYear = @"2018";
          request.cvv = @"100";
          request.shouldValidate = YES;

          [testClient saveCardWithRequest:request
                                  success:^(BTCardPaymentMethod *card){
                                      NSString *aNonce = card.nonce;
                                      [testClient fetchPaymentMethodWithNonce:aNonce
                                                                      success:^(BTPaymentMethod *paymentMethod) {
                                                                          expect(paymentMethod).to.beKindOf([BTCardPaymentMethod class]);

                                                                          BTCardPaymentMethod *cardPaymentMethod = (BTCardPaymentMethod *)paymentMethod;
                                                                          expect(cardPaymentMethod.lastTwo).to.equal(@"11");
                                                                          expect(cardPaymentMethod.type).to.equal(BTCardTypeVisa);
                                                                          [expectation fulfill];
                                                                      }
                                                                      failure:nil];
                                  }
                                  failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"get nonce", ^{
      it(@"gets an info dictionary about a nonce", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
          BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
          request.number = @"4111111111111111";
          request.expirationMonth = @"12";
          request.expirationYear = @"2018";
          request.shouldValidate = YES;

          [testClient saveCardWithRequest:request
                                  success:^(BTPaymentMethod *card){
                                      NSString *aNonce = card.nonce;
                                      [testClient fetchNonceInfo:aNonce success:^(NSDictionary *nonceInfo) {
                                          expect(nonceInfo).to.beKindOf([NSDictionary class]);
                                          [expectation fulfill];
                                      }
                                                         failure:nil];
                                  } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"fails to get information about a non-existent nonce", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to fetch info"];
          [testClient fetchNonceInfo:@"non-existent-nonce" success:nil failure:^(NSError *error) {
              expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
              expect(error.code).to.equal(BTMerchantIntegrationErrorNonceNotFound);
              [expectation fulfill];
          }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"fails to get information about a poorly formatted nonce", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to fetch info"];
          [testClient fetchNonceInfo:@"?strange/nonce&private_key=foo&stuff%20more" success:nil failure:^(NSError *error) {
              expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
              expect(error.code).to.equal(BTMerchantIntegrationErrorNonceNotFound);
              [expectation fulfill];
          }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"clients with Apple Pay activated", ^{
      if ([PKPayment class]) {
          it(@"can save an Apple Pay payment based on a PKPayment if Apple Pay is supported", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save Apple Pay card"];

              id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
              id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];

              [[[payment stub] andReturn:paymentToken] token];
              [[[payment stub] andReturn:nil] shippingMethod];
              [[[paymentToken stub] andReturn:[NSData data]] paymentData];
              [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
              [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
              [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];

              [testClient saveApplePayPayment:payment success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                  expect(applePayPaymentMethod.nonce).to.beANonce();
                  expect(applePayPaymentMethod.shippingAddress).to.beNil();
                  expect(applePayPaymentMethod.billingAddress).to.beNil();
                  expect(applePayPaymentMethod.shippingMethod).to.beNil();
                  [expectation fulfill];
              } failure:^(NSError *error) {
                  if (error) {
                      NSLog(@"ERROR: Make sure Apple Pay is enabled for integration_merchant_id in the Gateway.");
                      XCTFail(@"error = %@", error);
                  }
              }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

              
          it(@"can save an Apple Pay payment based on a PKPayment if Apple Pay is supported and return contact information alongside the nonce", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save apple pay card"];
              id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
              id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];
              
              ABRecordRef shippingAddress = ABPersonCreate();
              ABRecordRef billingAddress = ABPersonCreate();
              PKShippingMethod *shippingMethod = [PKShippingMethod summaryItemWithLabel:@"Shipping Method" amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
              shippingMethod.detail = @"detail";
              shippingMethod.identifier = @"identifier";
              
              [[[payment stub] andReturn:paymentToken] token];
              [[[payment stub] andReturnValue:OCMOCK_VALUE((void *)shippingAddress)] shippingAddress];
              [[[payment stub] andReturnValue:OCMOCK_VALUE((void *)billingAddress)] billingAddress];
              PKContact *billingContact = [[PKContact alloc] init];
              billingContact.emailAddress = @"billing@example.com";
              OCMStub([payment billingContact]).andReturn(billingContact);
              PKContact *shippingContact = [[PKContact alloc] init];
              shippingContact.emailAddress = @"shipping@example.com";
              OCMStub([payment shippingContact]).andReturn(shippingContact);
              [[[payment stub] andReturn:shippingMethod] shippingMethod];
              [[[paymentToken stub] andReturn:[NSData data]] paymentData];
              [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
              [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
              [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];
              
              [testClient saveApplePayPayment:payment success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                  expect(applePayPaymentMethod.nonce).to.beANonce();
                  expect(applePayPaymentMethod.shippingAddress == shippingAddress).to.equal(YES);
                  expect(applePayPaymentMethod.billingAddress == billingAddress).to.equal(YES);
                  expect(applePayPaymentMethod.shippingContact).to.equal(shippingContact);
                  expect(applePayPaymentMethod.billingContact).to.equal(billingContact);
                  expect(applePayPaymentMethod.shippingMethod.label).to.equal(shippingMethod.label);
                  expect(applePayPaymentMethod.shippingMethod.amount).to.equal(shippingMethod.amount);
                  expect(applePayPaymentMethod.shippingMethod.detail).to.equal(shippingMethod.detail);
                  expect(applePayPaymentMethod.shippingMethod.identifier).to.equal(shippingMethod.identifier);
                  [expectation fulfill];
              } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      }
  });


  describe(@"clients with PayPal activated", ^{
      __block BTClient *testClient;
      beforeEach(^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client"];
          [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                                   BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                   BTClientTestConfigurationKeyCustomer: @YES }
                                     async:asyncClient completion:^(BTClient *client) {
                                         testClient = client;
                                         [expectation fulfill];
                                     }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"can save a PayPal payment method based on an auth code", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save payment method"];
          [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
                                 applicationCorrelationID:@"testCorrelationId"
                                                  success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
                                                      expect(payPalPaymentMethod.nonce).to.beANonce();
                                                      expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
                                                      [expectation fulfill];
                                                  } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"can save a PayPal payment method based on an auth code without a correlation id", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save payment method"];
          [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
                                 applicationCorrelationID:nil
                                                  success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
                                                      expect(payPalPaymentMethod.nonce).to.beANonce();
                                                      expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
                                                      [expectation fulfill];
                                                  } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
      
      it(@"can save a PayPal payment method that includes address information when an additional address scope is set", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Save payment method"];
          testClient.additionalPayPalScopes = [NSSet setWithObject:@"address"];
          [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
                                 applicationCorrelationID:@"testCorrelationId"
                                                  success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
                                                      expect(payPalPaymentMethod.nonce).to.beANonce();
                                                      expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
                                                      expect(payPalPaymentMethod.billingAddress).toNot.beNil();
                                                      expect(payPalPaymentMethod.billingAddress.streetAddress).to.beKindOf([NSString class]);
                                                      expect(payPalPaymentMethod.billingAddress.extendedAddress).to.beKindOf([NSString class]);
                                                      expect(payPalPaymentMethod.billingAddress.locality).to.beKindOf([NSString class]);
                                                      expect(payPalPaymentMethod.billingAddress.region).to.beKindOf([NSString class]);
                                                      expect(payPalPaymentMethod.billingAddress.postalCode).to.beKindOf([NSString class]);
                                                      expect(payPalPaymentMethod.billingAddress.countryCodeAlpha2).to.beKindOf([NSString class]);
                                                      [expectation fulfill];
                                                  } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"a client initialized with a revoked authorization fingerprint", ^{
      beforeEach(^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Revoke authorization fingerprint"];
          [testClient revokeAuthorizationFingerprintForTestingWithSuccess:^{
              [expectation fulfill];
          } failure:nil];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"invokes the failure block for list payment methods", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch payment methods"];
          [testClient fetchPaymentMethodsWithSuccess:nil failure:^(NSError *error) {
              expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
              expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);
              [expectation fulfill];
          }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"noops for list cards if the failure block is nil", ^{
          [testClient fetchPaymentMethodsWithSuccess:nil failure:nil];

          XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for potential async exceptions"];
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
              [expectation fulfill];
          });
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"invokes the failure block for save card", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fails to save card"];
          BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
          request.number = @"4111111111111111";
          request.expirationMonth = @"12";
          request.expirationYear = @"2018";
          request.shouldValidate = NO;
          [testClient saveCardWithRequest:request
                                  success:nil
                                  failure:^(NSError *error) {
                                      expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                      expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);
                                      [expectation fulfill];
                                  }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"noops for save card if the failure block is nil", ^{
          BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
          request.number = @"4111111111111111";
          request.expirationMonth = @"12";
          request.expirationYear = @"2018";
          request.shouldValidate = YES;
          [testClient saveCardWithRequest:request
                                  success:nil
                                  failure:nil];

          XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for potential async exceptions"];
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
              [expectation fulfill];
          });
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"post analytics event", ^{
      it(@"sends an analytics event", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Post analytics event"];
          [BTClient testClientWithConfiguration:@{
                                                  BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                  BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                  BTClientTestConfigurationKeyCustomer:@YES,
                                                  BTClientTestConfigurationKeyClientTokenVersion: @2
                                                  } async:asyncClient completion:^(BTClient *client) {
                                                      testClient = client;
                                                      NSString *event = @"hello world! 🐴";
                                                      [testClient postAnalyticsEvent:event
                                                                             success:^{
                                                                                 [expectation fulfill];
                                                                             }
                                                                             failure:nil];
                                                  }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      it(@"is successful but does not send the event when analytics URL is omitted from the client token", ^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Post analytics event"];
          [BTClient testClientWithConfiguration:@{
                                                  BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                  BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                  BTClientTestConfigurationKeyCustomer:@YES,
                                                  BTClientTestConfigurationKeyAnalytics: [NSNull null],
                                                  BTClientTestConfigurationKeyClientTokenVersion: @2
                                                  } async:asyncClient completion:^(BTClient *client) {
                                                      NSString *event = @"hello world! 🐴";
                                                      [client postAnalyticsEvent:event
                                                                         success:^{
                                                                             [expectation fulfill];
                                                                         }
                                                                         failure:nil];
                                                  }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });
  });

  describe(@"3D Secure", ^{
      __block BTClient *testThreeDSecureClient;

      beforeEach(^{
          XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client"];
          NSDictionary *configuration = @{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                           BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                           BTClientTestConfigurationKeyMerchantAccountIdentifier: @"three_d_secure_merchant_account",
                                           BTClientTestConfigurationKeyClientTokenVersion: @2 };
          [BTClient testClientWithConfiguration:configuration
                                     async:asyncClient completion:^(BTClient *testClient) {
                                         testThreeDSecureClient = testClient;
                                         [expectation fulfill];
                                     }];
          [self waitForExpectationsWithTimeout:10 handler:nil];
      });

      describe(@"of an eligible Visa", ^{
          __block NSString *nonce;

          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
              r.number = @"4010000000000018";
              r.expirationDate = @"12/2015";

              [testThreeDSecureClient saveCardWithRequest:r
                                                  success:^(BTCardPaymentMethod *card) {
                                                      nonce = card.nonce;
                                                      [expectation fulfill];
                                                  }
                                                  failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"performs lookup to give a new nonce and other parameters that allow you to kick off a web-based auth flow", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
              [testThreeDSecureClient
               lookupNonceForThreeDSecure:nonce
               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
               success:^(BTThreeDSecureLookupResult *threeDSecureLookupResult) {
                   expect(threeDSecureLookupResult.requiresUserAuthentication).to.beTruthy();
                   expect(threeDSecureLookupResult.MD).to.beKindOf([NSString class]);
                   expect(threeDSecureLookupResult.acsURL).to.equal([NSURL URLWithString:@"https://testcustomer34.cardinalcommerce.com/V3DSStart?osb=visa-3&VAA=B"]);
                   expect([threeDSecureLookupResult.termURL absoluteString]).to.match(@"/merchants/integration_merchant_id/client_api/v1/payment_methods/[a-fA-F0-9-]+/three_d_secure/authenticate\?.*");
                   expect(threeDSecureLookupResult.PAReq).to.beKindOf([NSString class]);

                   [expectation fulfill];
               }
               failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"of an unenrolled Visa", ^{
          __block NSString *nonce;

          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
              r.number = @"4000000000000051";
              r.expirationDate = @"01/2020";

              [testThreeDSecureClient saveCardWithRequest:r
                                                  success:^(BTCardPaymentMethod *card) {
                                                      nonce = card.nonce;
                                                      [expectation fulfill];
                                                  }
                                                  failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"succeeds without further intervention, since the liability shifts without authentication ", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
              [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                         success:^(BTThreeDSecureLookupResult *threeDSecureLookup) {
                                                             expect(threeDSecureLookup.requiresUserAuthentication).to.beFalsy();
                                                             expect(threeDSecureLookup.card.nonce).to.beANonce();
                                                             expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]).to.beTruthy();
                                                             expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]).to.beTruthy();
                                                             [expectation fulfill];
                                                         } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"of an enrolled, issuer unavailable card", ^{
          __block NSString *nonce;

          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
              r.number = @"4000000000000069";
              r.expirationDate = @"01/2020";

              [testThreeDSecureClient saveCardWithRequest:r
                                                  success:^(BTCardPaymentMethod *card) {
                                                      nonce = card.nonce;
                                                      [expectation fulfill];
                                                  }
                                                  failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"performs lookup to give a new nonce without other parameters since no web-based auth flow is required", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
              [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                         success:^(BTThreeDSecureLookupResult *threeDSecureLookup) {
                                                             expect(threeDSecureLookup.requiresUserAuthentication).to.beFalsy();
                                                             expect(threeDSecureLookup.card.nonce).to.beANonce();
                                                             expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]).to.beFalsy();
                                                             expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]).to.beFalsy();
                                                             [expectation fulfill];
                                                         } failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"of an ineligible card type", ^{
          __block NSString *nonce;

          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
              BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
              r.number = @"6011111111111117";
              r.expirationDate = @"01/2020";

              [testThreeDSecureClient saveCardWithRequest:r
                                                  success:^(BTCardPaymentMethod *card) {
                                                      nonce = card.nonce;
                                                      [expectation fulfill];
                                                  }
                                                  failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"succeeds without a liability shift", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
              [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                         success:^(BTThreeDSecureLookupResult *threeDSecureLookup) {
                                                             expect(threeDSecureLookup.requiresUserAuthentication).to.beFalsy();
                                                             expect(threeDSecureLookup.card.nonce).to.beANonce();
                                                             expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]).to.beFalsy();
                                                             expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]).to.beFalsy();
                                                             [expectation fulfill];
                                                         }
                                                         failure:nil];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          describe(@"of an invalid card nonce", ^{
              __block NSString *nonce;

              beforeEach(^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
                  BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                  r.number = @"not a card number";
                  r.expirationDate = @"12/2020";

                  [testThreeDSecureClient saveCardWithRequest:r
                                                      success:^(BTCardPaymentMethod *card) {
                                                          nonce = card.nonce;
                                                          [expectation fulfill];
                                                      }
                                                      failure:nil];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });

              it(@"fails to perform a lookup", ^{
                  XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to perform lookup"];
                  [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                                   transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                             success:nil
                                                             failure:^(NSError *error) {
                                                                 expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                 expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                 expect(error.localizedDescription).to.contain(@"Credit card number is invalid");
                                                                 expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.equal(@{ @"message": @"Credit card number is invalid" });
                                                                 expect(error.userInfo[BTThreeDSecureInfoKey]).to.equal(@{ @"liabilityShiftPossible": @0, @"liabilityShifted": @0, });
                                                                 [expectation fulfill];
                                                             }];
                  [self waitForExpectationsWithTimeout:10 handler:nil];
              });
          });
      });

      describe(@"of a non-card nonce", ^{
          __block NSString *nonce;
          __block BTClient *testPayPalClient;
          
          beforeEach(^{
              XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Fetch client that supports PayPal"];
              NSDictionary *configuration = @{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                               BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                               BTClientTestConfigurationKeyMerchantAccountIdentifier: @"sandbox_credit_card",
                                               BTClientTestConfigurationKeyClientTokenVersion: @2 };
              [BTClient testClientWithConfiguration:configuration
                                              async:asyncClient completion:^(BTClient *testClient) {
                                                  testPayPalClient = testClient;
                                                  [clientExpectation fulfill];
                                              }];
              [self waitForExpectationsWithTimeout:5 handler:nil];
              
              XCTestExpectation *expectation = [self expectationWithDescription:@"Get PayPal nonce"];
              [testPayPalClient savePaypalPaymentMethodWithAuthCode:@"fake-paypal-auth-code"
                                           applicationCorrelationID:nil
                                                            success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                nonce = paypalPaymentMethod.nonce;
                                                                [expectation fulfill];
                                                            } failure:^(NSError *error) {
                                                                XCTFail(@"Unexpected error: %@", error);
                                                            }];
              [self waitForExpectationsWithTimeout:5 handler:nil];
          });

          it(@"fails to perform a lookup", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to perform lookup"];
              [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                         success:nil
                                                         failure:^(NSError *error) {
                                                             expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                             expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                             expect(error.localizedDescription).to.contain(@"Cannot 3D Secure a non-credit card payment instrument");
                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
                                                             [expectation fulfill];
                                                         }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"unregistered 3DS merchant", ^{
          __block NSString *nonce;

          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
              [BTClient testClientWithConfiguration:@{
                                                      BTClientTestConfigurationKeyMerchantIdentifier: @"altpay_merchant",
                                                      BTClientTestConfigurationKeyPublicKey: @"altpay_merchant_public_key",
                                                      BTClientTestConfigurationKeyClientTokenVersion: @2
                                                      } async:asyncClient completion:^(BTClient *testClient) {
                                                          testThreeDSecureClient = testClient;
                                                          BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                                                          r.number = @"4000000000000051";
                                                          r.expirationDate = @"01/2020";

                                                          [testThreeDSecureClient saveCardWithRequest:r
                                                                                              success:^(BTCardPaymentMethod *card) {
                                                                                                  nonce = card.nonce;
                                                                                                  [expectation fulfill];
                                                                                              }
                                                                                              failure:nil];
                                                      }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });

          it(@"fails to lookup", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to perform lookup"];
              [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                         success:nil
                                                         failure:^(NSError *error) {
                                                             expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                             expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                             expect(error.localizedDescription).to.contain(@"Merchant account not 3D Secure enabled");
                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
                                                             [expectation fulfill];
                                                         }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });

      describe(@"unregistered 3DS merchant accounts", ^{
          __block NSString *nonce;

          beforeEach(^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
              [BTClient testClientWithConfiguration:@{
                                                      BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                                      BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                      BTClientTestConfigurationKeyClientTokenVersion: @2
                                                      } async:asyncClient completion:^(BTClient *testClient) {
                                                          testThreeDSecureClient = testClient;
                                                          BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                                                          r.number = @"4000000000000051";
                                                          r.expirationDate = @"01/2020";

                                                          [testThreeDSecureClient saveCardWithRequest:r
                                                                                              success:^(BTCardPaymentMethod *card) {
                                                                                                  nonce = card.nonce;
                                                                                                  [expectation fulfill];
                                                                                              }
                                                                                              failure:nil];
                                                      }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
          
          it(@"fails to lookup", ^{
              XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to lookup"];
              [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                               transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                         success:nil
                                                         failure:^(NSError *error) {
                                                             expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                             expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                             expect(error.localizedDescription).to.contain(@"Merchant account not 3D Secure enabled");
                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
                                                             [expectation fulfill];
                                                         }];
              [self waitForExpectationsWithTimeout:10 handler:nil];
          });
      });
  });

});

SharedExamplesEnd

SpecBegin(DeprecatedBTClient)

describe(@"shared initialization behavior", ^{
  NSDictionary* data = @{@"asyncClient": @NO};
  itShouldBehaveLike(@"a BTClient", data);
});

SpecEnd

SpecBegin(AsyncBTClient)

describe(@"shared initialization behavior", ^{
  NSDictionary* data = @{@"asyncClient": @YES};
  itShouldBehaveLike(@"a BTClient", data);
});

SpecEnd

