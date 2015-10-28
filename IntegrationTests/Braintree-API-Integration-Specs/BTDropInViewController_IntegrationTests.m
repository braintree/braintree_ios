//#import <XCTest/XCTest.h>
//
//@interface BTDropInViewController_IntegrationTests : XCTestCase
//
//@end
//
//@implementation BTDropInViewController_IntegrationTests{
//    BTAPIClient *client;
//}
//
//- (void)setUp {
//    [super setUp];
//    client = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}
//
//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}
//
//// Fetch vaulted payment methods
//- (void)testPaymentMethodsAreDisplayed {
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch payment methods"];
//
//    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithClient:client];
//    [UIApplication ]
//    dropInViewController
//
//
//    [self presentViewController]
//
//
//    // TODO: Authenticate customer
//    [client setCurrentCustomerWithJWT:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"];
//
//    client.activeCustomer = @"test_customer";
//
//    [client fetchPaymentMethods:^(NSArray *paymentMethods, NSError *error) {
//        XCTAssertNotNil(paymentMethods);
//        XCTAssert(paymentMethods.count > 0);
//        XCTAssertNil(error);
//        [expectation fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//@end




//
//    describe(@"list payment methods", ^{
//        __block BTPaymentMethod *card1, *card2;
//
//        beforeEach(^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Save cards"];
//            BTClientCardRequest *request1 = [[BTClientCardRequest alloc] init];
//            request1.number = @"4111111111111111";
//            request1.expirationMonth = @"12";
//            request1.expirationYear = @"2018";
//            request1.shouldValidate = YES;
//
//            [testClient saveCardWithRequest:request1
//                                    success:^(BTPaymentMethod *card) {
//                                        card1 = card;
//                                        BTClientCardRequest *request2 = [[BTClientCardRequest alloc] init];
//
//                                        request2.number = @"5555555555554444";
//                                        request2.expirationDate = @"03/2016";
//                                        request2.shouldValidate = YES;
//
//                                        [testClient saveCardWithRequest:request2
//                                                                success:^(BTPaymentMethod *card) {
//                                                                    card2 = card;
//                                                                    [expectation fulfill];
//                                                                } failure:nil];
//                                    } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"fetches a list of payment methods", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch payment methods"];
//            [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
//                expect(paymentMethods).to.haveCountOf(2);
//                expect([paymentMethods[0] nonce]).to.beANonce();
//                expect([paymentMethods[1] nonce]).to.beANonce();
//                [expectation fulfill];
//            } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"saves two cards and returns them in subsequent calls to list cards", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Save two cards"];
//            BTClientCardRequest *request1 = [[BTClientCardRequest alloc] init];
//            request1.number = @"4111111111111111";
//            request1.expirationMonth = @"12";
//            request1.expirationYear = @"2018";
//            request1.shouldValidate = YES;
//
//            [testClient saveCardWithRequest:request1
//                                    success:^(BTPaymentMethod *card1){
//                                        BTClientCardRequest *request2 = [[BTClientCardRequest alloc] init];
//                                        request2.number = @"5555555555554444";
//                                        request2.expirationMonth = @"3";
//                                        request2.expirationYear = @"2016";
//                                        request2.shouldValidate = YES;
//
//                                        [testClient saveCardWithRequest:request2
//                                                                success:^(BTPaymentMethod *card2){
//                                                                    [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
//                                                                        expect(paymentMethods).to.haveCountOf(2);
//
//                                                                        [expectation fulfill];
//                                                                    } failure:nil];
//                                                                } failure:nil];
//                                    } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//    });
//
//    describe(@"show payment method", ^{
//        it(@"gets a full representation of a payment method based on a nonce", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Save and fetch payment method"];
//            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
//            request.number = @"4111111111111111";
//            request.expirationMonth = @"12";
//            request.expirationYear = @"2018";
//            request.cvv = @"100";
//            request.shouldValidate = YES;
//
//            [testClient saveCardWithRequest:request
//                                    success:^(BTCardPaymentMethod *card){
//                                        NSString *aNonce = card.nonce;
//                                        [testClient fetchPaymentMethodWithNonce:aNonce
//                                                                        success:^(BTPaymentMethod *paymentMethod) {
//                                                                            expect(paymentMethod).to.beKindOf([BTCardPaymentMethod class]);
//
//                                                                            BTCardPaymentMethod *cardPaymentMethod = (BTCardPaymentMethod *)paymentMethod;
//                                                                            expect(cardPaymentMethod.lastTwo).to.equal(@"11");
//                                                                            expect(cardPaymentMethod.type).to.equal(BTCardTypeVisa);
//                                                                            [expectation fulfill];
//                                                                        }
//                                                                        failure:nil];
//                                    }
//                                    failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//    });
//

//
// MARK: - _meta parameter for card form
//
//func testMetadata_whenCardFormTokenizationIsSuccessful_isPOSTedToServer() {
//    let mockAPIClient = MockAPIClient(authorization: "development_testing_integration_merchant_id")!
//    let dropIn = BTDropInViewController(APIClient: mockAPIClient)
//    
//    
//    
//    XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
//    guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
//        XCTFail()
//        return
//    }
//    let metaParameters = lastPostParameters["_meta"] as! NSDictionary
//    XCTAssertEqual(metaParameters["source"] as? String, "paypal-browser")
//    XCTAssertEqual(metaParameters["integration"] as? String, "custom")
//    XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
//}
//
