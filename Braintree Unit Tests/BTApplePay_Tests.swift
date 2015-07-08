import Braintree
import XCTest

class BTApplePay_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testApplePay() {
        let mockClient = MockAPIClient(clientKey: "test_client_key")
    }

    //

    class MockAPIClient : BTAPIClient {
        var lastPOSTPath = ""
        var lastPOSTParameters = [:] as [NSObject : AnyObject]
        var cannedConfigurationError : NSError? = nil
        var cannedPOSTError : NSError? = nil

        override func POST(path: String, parameters: [NSObject : AnyObject], completion completionBlock: (BTJSON?, NSHTTPURLResponse?, NSError?) -> Void) {
            self.lastPOSTPath = path
            self.lastPOSTParameters = parameters

            if cannedPOSTError != nil {
                completionBlock(nil, nil, cannedPOSTError)
                return;
            }

            let body = BTJSON(value: [
                "paymentResource": [
                    "redirectURL": "fakeURL://"
                ] ])

            completionBlock(body, nil, nil)
        }

        override func fetchOrReturnRemoteConfiguration(completionBlock: (BTJSON?, NSError?) -> Void) {
            if cannedConfigurationError != nil {
                completionBlock(nil, cannedConfigurationError)
                return;
            }

            let config = BTJSON(value: [
                "paypal": [
                    "environment": "offline"
                ] ])
            
            completionBlock(config, nil)
        }
    }

}















//
//
//if (![PKPayment class]) {
//    if (failureBlock) {
//        failureBlock([NSError errorWithDomain:BTBraintreeAPIErrorDomain
//            code:BTErrorUnsupported
//            userInfo:@{NSLocalizedDescriptionKey: @"Apple Pay is not supported on this device"}]);
//    }
//    return;
//
//}
//
//NSString *encodedPaymentData;
//NSError *error;
//switch (self.configuration.applePayStatus) {
//case BTClientApplePayStatusOff:
//    error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
//        code:BTErrorUnsupported
//        userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not enabled for this merchant. Please ensure that Apple Pay is enabled in the control panel and then try saving an Apple Pay payment method again." }];
//    [[BTLogger sharedLogger] warning:error.localizedDescription];
//    break;
//case BTClientApplePayStatusMock: {
//    NSDictionary *mockPaymentDataDictionary = @{
//        @"version": @"hello-version",
//        @"data": @"hello-data",
//        @"header": @{
//            @"transactionId": @"hello-transaction-id",
//            @"ephemeralPublicKey": @"hello-ephemeral-public-key",
//            @"publicKeyHash": @"hello-public-key-hash"
//        }};
//    NSError *error;
//    NSData *paymentData = [NSJSONSerialization dataWithJSONObject:mockPaymentDataDictionary options:0 error:&error];
//    NSAssert(error == nil, @"Unexpected JSON serialization error: %@", error);
//    encodedPaymentData = [paymentData base64EncodedStringWithOptions:0];
//    break;
//    }
//
//case BTClientApplePayStatusProduction:
//    if (!payment) {
//        [[BTLogger sharedLogger] warning:@"-[BTClient saveApplePayPayment:success:failure:] received nil payment."];
//        NSError *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
//        code:BTErrorUnsupported
//        userInfo:@{NSLocalizedDescriptionKey: @"A valid PKPayment is required in production"}];
//        if (failureBlock) {
//            failureBlock(error);
//        }
//        return;
//    }
//
//    encodedPaymentData = [payment.token.paymentData base64EncodedStringWithOptions:0];
//    break;
//default:
//    return;
//}
//
//if (error) {
//    if (failureBlock) {
//        failureBlock(error);
//    }
//    return;
//}
//
//NSMutableDictionary *tokenParameterValue = [NSMutableDictionary dictionary];
//if (encodedPaymentData) {
//    tokenParameterValue[@"paymentData"] = encodedPaymentData;
//}
//if (payment.token.paymentInstrumentName) {
//    tokenParameterValue[@"paymentInstrumentName"] = payment.token.paymentInstrumentName;
//}
//if (payment.token.transactionIdentifier) {
//    tokenParameterValue[@"transactionIdentifier"] = payment.token.transactionIdentifier;
//}
//if (payment.token.paymentNetwork) {
//    tokenParameterValue[@"paymentNetwork"] = payment.token.paymentNetwork;
//}
//
//NSMutableDictionary *requestParameters = [self metaPostParameters];
//[requestParameters addEntriesFromDictionary:@{ @"applePaymentToken": tokenParameterValue,
//    @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
//}];
//
//[self.clientApiHttp POST:@"v1/payment_methods/apple_payment_tokens" parameters:requestParameters completion:^(BTHTTPResponse *response, NSError *error){
//if (response.isSuccess) {
//if (successBlock){
//NSArray *applePayCards = [response.object arrayForKey:@"applePayCards" withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];
//
//BTMutableApplePayPaymentMethod *paymentMethod = [applePayCards firstObject];
//
//paymentMethod.shippingAddress = payment.shippingAddress;
//paymentMethod.shippingMethod = payment.shippingMethod;
//paymentMethod.billingAddress = payment.billingAddress;
//
//successBlock([paymentMethod copy]);
//}
//} else {
//if (failureBlock) {
//NSDictionary *userInfo;
//if (error) {
//userInfo = @{NSUnderlyingErrorKey: error,
//@"statusCode": @(response.statusCode)};
//}
//failureBlock([NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTUnknownError userInfo:userInfo]);
//}
//}
//}];
//}