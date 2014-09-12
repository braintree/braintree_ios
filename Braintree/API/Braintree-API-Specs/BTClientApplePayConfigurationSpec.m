#import "BTClientApplePayConfiguration.h"

SpecBegin(BTClientApplePayConfiguration)

describe(@"initWithDictionary:", ^{

    it(@"is initialized with a dictionary", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"merchantId": @"123"}];
        expect(configuration.enabled).to.beTruthy();
        expect(configuration.merchantId).to.equal(@"123");
    });

    it(@"is initialized and enabled even with an empty dictionary", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"merchantId": @"123"}];
        expect(configuration.enabled).to.beTruthy();
    });


    it(@"is not enabled if initialized with nil dictionary", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:nil];
        expect(configuration.enabled).to.beFalsy();
        
    });
});

SpecEnd
