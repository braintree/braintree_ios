#import "BTClientToken.h"
#import "BTClient+BTPaymentApplePay.h"

NSString *clientTokenStringFromNSDictionary(NSDictionary *dictionary) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

SpecBegin(BTClient_BTVenmo)

__block NSMutableDictionary *baseClientTokenClaims;

beforeEach(^{

    baseClientTokenClaims = [NSMutableDictionary dictionaryWithDictionary:@{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                                                             BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api"}];

});

describe(@"btPayment_applePayConfiguration", ^{

    it(@"returns an instance of BTPaymentsApplePayConfiguration", ^{
        NSString *clientTokenString = clientTokenStringFromNSDictionary(baseClientTokenClaims);
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btPayment_applePayConfiguration).to.beKindOf([BTPaymentApplePayConfiguration class]);
    });

    it(@"is disabled if no applePay key is present", ^{
        NSString *clientTokenString = clientTokenStringFromNSDictionary(baseClientTokenClaims);
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btPayment_applePayConfiguration.enabled).to.beFalsy();
    });

    it(@"is enabled if an applePay key has a dictionary value", ^{
        baseClientTokenClaims[@"applePay"] = @{};
        NSString *clientTokenString = clientTokenStringFromNSDictionary(baseClientTokenClaims);
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btPayment_applePayConfiguration.enabled).to.beTruthy();
        expect(client.btPayment_applePayConfiguration.merchantId).to.beNil();
    });

    it(@"is enabled and has a merchantId if applePay value has a merchantId entry", ^{
        baseClientTokenClaims[@"applePay"] = @{@"merchantId": @"abcd"};
        NSString *clientTokenString = clientTokenStringFromNSDictionary(baseClientTokenClaims);
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btPayment_applePayConfiguration.enabled).to.beTruthy();
        expect(client.btPayment_applePayConfiguration.merchantId).to.equal(@"abcd");
    });

});

SpecEnd