#import "BTPaymentApplePayConfiguration.h"

SpecBegin(BTPaymentApplePayConfiguration)

describe(@"initWithDictionary:", ^{

    it(@"is initialized with a dictionary", ^{
        BTPaymentApplePayConfiguration *configuration = [[BTPaymentApplePayConfiguration alloc] initWithDictionary:@{@"merchantId": @"123"}];
        expect(configuration.enabled).to.beTruthy();
        expect(configuration.merchantId).to.equal(@"123");
    });

    it(@"is initialized and enabled even with an empty dictionary", ^{
        BTPaymentApplePayConfiguration *configuration = [[BTPaymentApplePayConfiguration alloc] initWithDictionary:@{@"merchantId": @"123"}];
        expect(configuration.enabled).to.beTruthy();
    });


    it(@"is not enabled if initialized with nil dictionary", ^{
        BTPaymentApplePayConfiguration *configuration = [[BTPaymentApplePayConfiguration alloc] initWithDictionary:nil];
        expect(configuration.enabled).to.beFalsy();
        
    });
});

SpecEnd
