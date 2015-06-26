#import "BTClient_Internal.h"
#import "BTClient+Testing.h"

SpecBegin(BTClientCoinbaseIntegrationSpec)

__block BTClient *testClient;

beforeEach(^{
    XCTestExpectation *fetchTestClientTokenExpectation = [self expectationWithDescription:@"Fetch test client"];
    [BTClient testClientWithConfiguration:@{
                                            BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                            BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                            BTClientTestConfigurationKeyCustomer:@YES,
                                            BTClientTestConfigurationKeyClientTokenVersion: @2
                                            } async:YES completion:^(BTClient *client) {
                                                testClient = client;
                                                [testClient updateCoinbaseMerchantOptions:@{ @"enabled": @YES }
                                                                                  success:^{
                                                                                      [fetchTestClientTokenExpectation fulfill];
                                                                                  } failure:^(NSError *error) {
                                                                                      XCTFail(@"Should not receive call to failure block");
                                                                                  }];
                                            }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
});

afterEach(^{
    XCTestExpectation *fetchTestClientTokenExpectation = [self expectationWithDescription:@"Fetch test client"];
    [testClient updateCoinbaseMerchantOptions:@{ @"enabled": @NO }
                                      success:^{
                                          [fetchTestClientTokenExpectation fulfill];
                                      } failure:nil];
    [self waitForExpectationsWithTimeout:10 handler:nil];
});

describe(@"saveCoinbaseAccount:storeInVault:success:failure:", ^{
    it(@"returns a valid response including a nonce in the happy path", ^{
        XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize Coinbase account"];
        id coinbaseResponse = @{ @"code": @"fake_coinbase_auth_code" };
        [testClient saveCoinbaseAccount:coinbaseResponse
                           storeInVault:NO
                                success:^(BTCoinbasePaymentMethod *coinbase){
                                    XCTAssertTrue([coinbase isKindOfClass:[BTCoinbasePaymentMethod class]]);
                                    expect(coinbase.nonce).to.beANonce();
                                    XCTAssertNotNil(coinbase.email);
                                    XCTAssertNotNil(coinbase.description);
                                    [tokenizationExpectation fulfill];
                                } failure:^(NSError *error){
                                    XCTFail(@"Should not receive call to Coinbase tokenization failure block");
                                }];
        
        [self waitForExpectationsWithTimeout:10 handler:nil];
    });

    it(@"returns an error when tokenizing an invalid auth code", ^{
        XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize invalid auth code"];
        id coinbaseResponse = @{ @"code": @"fake_coinbase_invalid_authorization_code" };
        [testClient saveCoinbaseAccount:coinbaseResponse
                           storeInVault:NO
                                success:^(BTCoinbasePaymentMethod *coinbase){
                                    XCTFail(@"Should not receive call to Coinbase tokenization success block");
                                } failure:^(NSError *error){
                                    expect([error domain]).to.equal(BTBraintreeAPIErrorDomain);
                                    expect([error code]).to.equal(BTCustomerInputErrorInvalid);
                                    expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"error"][@"message"]).to.equal(@"Rejecting fake invalid authorization code");
                                    [tokenizationExpectation fulfill];
                                }];

        [self waitForExpectationsWithTimeout:10 handler:nil];
    });

    it(@"returns an error when tokenizing malformed coinbase response", ^{
        XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize malformed coinbase response"];
        id coinbaseResponse = @"this is not a dictionary containing an auth code";
        [testClient saveCoinbaseAccount:coinbaseResponse
                           storeInVault:NO
                                success:^(BTCoinbasePaymentMethod *coinbase){
                                    XCTFail(@"Should not receive call to Coinbase tokenization success block");
                                } failure:^(NSError *error){
                                    XCTAssertTrue([error isKindOfClass:[NSError class]]);
                                    XCTAssertEqual([error domain], BTBraintreeAPIErrorDomain);
                                    XCTAssertEqual([error code], BTCustomerInputErrorInvalid);
                                    XCTAssertEqual([error localizedDescription], @"Received an invalid Coinbase response for tokenization, expected an NSDictionary");
                                    [tokenizationExpectation fulfill];
                                }];
        
        [self waitForExpectationsWithTimeout:10 handler:nil];
    });

    it(@"accepts a nil success block without crashing", ^{
        XCTestExpectation *completionExpectation = [self expectationWithDescription:@"BTHTTP called BTClient's completion block"];
        id mockClient = [OCMockObject partialMockForObject:testClient.clientApiHttp];
        
        id stub = [mockClient expect];
        [stub andDo:^(NSInvocation *invocation) {
            BTHTTPCompletionBlock completionBlock;
            [invocation getArgument:&completionBlock atIndex:4];
            id response = [OCMockObject mockForClass:[BTHTTPResponse class]];
            [[[response stub] andReturnValue:@(YES)] isSuccess];
            [[[response stub] andReturn:[BTAPIResponseParser parserWithDictionary:@{}]] object];
            completionBlock(response, nil);
            [completionExpectation fulfill];
        }];
        [stub POST:@"v1/payment_methods/coinbase_accounts"
        parameters:[OCMArg any]
        completion:[OCMArg any]];
        
        id coinbaseResponse = @{ @"code": @"1234" };
        [testClient saveCoinbaseAccount:coinbaseResponse
                           storeInVault:NO
                                success:nil
                                failure:^(NSError *error){
                                    XCTFail(@"Should not receive call to Coinbase tokenization failure block");
                                }];
        
        [mockClient verifyWithDelay:10];
        [self waitForExpectationsWithTimeout:10 handler:nil];
    });

    it(@"accepts a nil failure block without crashing", ^{
        XCTestExpectation *completionExpectation = [self expectationWithDescription:@"BTHTTP called BTClient's completion block"];
        id mockClient = [OCMockObject partialMockForObject:testClient.clientApiHttp];
        
        id stub = [mockClient expect];
        [stub andDo:^(NSInvocation *invocation) {
            BTHTTPCompletionBlock completionBlock;
            [invocation getArgument:&completionBlock atIndex:4];
            NSError *error = [OCMockObject mockForClass:[NSError class]];
            completionBlock(nil, error);
            [completionExpectation fulfill];
        }];
        [stub POST:@"v1/payment_methods/coinbase_accounts"
        parameters:[OCMArg any]
        completion:[OCMArg any]];
        
        id coinbaseResponse = @{ @"code": @"1234" };
        [testClient saveCoinbaseAccount:coinbaseResponse
                           storeInVault:NO
                                success:^(BTCoinbasePaymentMethod *coinbase){
                                    XCTFail(@"Should not receive call to Coinbase tokenization success block");
                                } failure:nil];
        
        [mockClient verifyWithDelay:10];
        [self waitForExpectationsWithTimeout:10 handler:nil];
    });

    describe(@"storeInVault", ^{
        it(@"stores the coinbase account in the customer's vault when YES", ^{
            XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize Coinbase account"];
            id coinbaseResponse = @{ @"code": @"fake_coinbase_auth_code" };
            [testClient saveCoinbaseAccount:coinbaseResponse
                               storeInVault:YES
                                    success:^(BTCoinbasePaymentMethod *coinbase){
                                        XCTAssertTrue([coinbase isKindOfClass:[BTCoinbasePaymentMethod class]]);
                                        [tokenizationExpectation fulfill];
                                    } failure:^(NSError *error){
                                        XCTFail(@"Should not receive call to Coinbase tokenization failure block");
                                    }];
            
            [self waitForExpectationsWithTimeout:10 handler:nil];
            
            XCTestExpectation *fetchPaymentMethodsExpectation = [self expectationWithDescription:@"Fetch Payment Methods"];
            [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                expect(paymentMethods).to.haveCountOf(1);
                expect(paymentMethods[0]).to.beKindOf([BTCoinbasePaymentMethod class]);
                [fetchPaymentMethodsExpectation fulfill];
            } failure:^(NSError *error) {
                XCTFail(@"Should not receive call to Fetch payment methods tokenization failure block");
            }];
            
            [self waitForExpectationsWithTimeout:10 handler:nil];
        });

        it(@"does not store the coinbase account in the customer's vault when NO", ^{
            XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize Coinbase account"];
            id coinbaseResponse = @{ @"code": @"fake_coinbase_auth_code" };
            [testClient saveCoinbaseAccount:coinbaseResponse
                               storeInVault:NO
                                    success:^(BTCoinbasePaymentMethod *coinbase){
                                        XCTAssertTrue([coinbase isKindOfClass:[BTCoinbasePaymentMethod class]]);
                                        [tokenizationExpectation fulfill];
                                    } failure:^(NSError *error){
                                        XCTFail(@"Should not receive call to Coinbase tokenization failure block");
                                    }];
            
            [self waitForExpectationsWithTimeout:10 handler:nil];

            XCTestExpectation *fetchPaymentMethodsExpectation = [self expectationWithDescription:@"Fetch Payment Methods"];
            [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                expect(paymentMethods).to.haveCountOf(0);
                [fetchPaymentMethodsExpectation fulfill];
            } failure:^(NSError *error) {
                XCTFail(@"Should not receive call to Fetch payment methods tokenization failure block");
            }];

            [self waitForExpectationsWithTimeout:10 handler:nil];
        });

        it(@"has no impact when no customer is present", ^{
            XCTestExpectation *fetchTestClientExpectation = [self expectationWithDescription:@"Fetch test client"];
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                    BTClientTestConfigurationKeyNoCustomer: @YES,
                                                    BTClientTestConfigurationKeyClientTokenVersion: @2
                                                    } async:YES completion:^(BTClient *client) {
                                                        testClient = client;
                                                        [testClient updateCoinbaseMerchantOptions:@{ @"enabled": @YES }
                                                                                          success:^{
                                                                                              [fetchTestClientExpectation fulfill];
                                                                                          } failure:^(NSError *error) {
                                                                                              XCTFail(@"Should not receive call to failure block");
                                                                                          }];
                                                    }];
            [self waitForExpectationsWithTimeout:10 handler:nil];
            
            XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize Coinbase account"];
            id coinbaseResponse = @{ @"code": @"fake_coinbase_auth_code" };
            [testClient saveCoinbaseAccount:coinbaseResponse
                               storeInVault:YES
                                    success:^(BTCoinbasePaymentMethod *coinbase){
                                        XCTAssertTrue([coinbase isKindOfClass:[BTCoinbasePaymentMethod class]]);
                                        [tokenizationExpectation fulfill];
                                    } failure:^(NSError *error){
                                        XCTFail(@"Should not receive call to Coinbase tokenization failure block");
                                    }];
            
            [self waitForExpectationsWithTimeout:10 handler:nil];
            
            XCTestExpectation *fetchPaymentMethodsExpectation = [self expectationWithDescription:@"Fetch Payment Methods"];
            [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                expect(paymentMethods).to.haveCountOf(0);
                [fetchPaymentMethodsExpectation fulfill];
            } failure:^(NSError *error) {
                XCTFail(@"Should not receive call to Fetch payment methods tokenization failure block");
            }];
            
            [self waitForExpectationsWithTimeout:10 handler:nil];
        });
    });
});

SpecEnd
