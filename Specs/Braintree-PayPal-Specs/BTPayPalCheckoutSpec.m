#import "BTPayPalCheckout.h"
#import "BTLogger_Internal.h"

SpecBegin(BTPayPalCheckoutSpec)

describe(@"checkoutWithAmount:", ^{
    it(@"initializes and retains the amount", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber decimalNumberWithString:@"9.99"]];
        expect(checkout.amount.doubleValue).to.equal(9.99);
    });
    
    it(@"defaults to shipping method collection disabled", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber decimalNumberWithString:@"1.23"]];
        expect(checkout.enableShippingAddress).to.beTruthy();
        expect(checkout.addressOverride).to.beFalsy();
        expect(checkout.shippingAddress).to.beNil();
        expect(checkout.localeCode).to.beNil();
    });
    
    it(@"requires an amount", ^{
        BTLogger *logger = OCMPartialMock([BTLogger sharedLogger]);
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:nil];
        expect(checkout).to.beNil();
        OCMVerify([logger log:HC_containsString(@"amount")]);
    });
    
    it(@"requires a non-negative amount", ^{
        BTLogger *logger = OCMPartialMock([BTLogger sharedLogger]);
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber decimalNumberWithString:@"-10.99"]];
        expect(checkout).to.beNil();
        OCMVerify([logger log:HC_containsString(@"amount")]);
    });
});

describe(@"disableShippingAddress", ^{
    it(@"retains the shipping address preference", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        checkout.enableShippingAddress = NO;
        expect(checkout.enableShippingAddress).to.beFalsy();
    });
});

describe(@"enableAddressOverride", ^{
    it(@"retains the address override preference", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        checkout.addressOverride = YES;
        expect(checkout.enableShippingAddress).to.beTruthy();
    });
});

describe(@"setLocalCode", ^{
    it(@"retains the locale code preference", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        checkout.localeCode = @"de_DE";
        expect(checkout.localeCode).to.equal(@"de_DE");
    });
});

describe(@"shippingAddress", ^{
    it(@"retains the specified shipping address override", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        BTPostalAddress *postalAddress = [[BTPostalAddress alloc] init];
        postalAddress.recipientName = @"Johnny";
        postalAddress.streetAddress = @"123 Fake St.";
        postalAddress.extendedAddress = @"Apt 2";
        postalAddress.locality = @"Oakland";
        postalAddress.region = @"CA";
        postalAddress.postalCode = @"94602";
        postalAddress.countryCodeAlpha2 = @"US";
        checkout.shippingAddress = postalAddress;
        expect(postalAddress.recipientName).to.equal(@"Johnny");
        expect(postalAddress.streetAddress).to.equal(@"123 Fake St.");
        expect(postalAddress.extendedAddress).to.equal(@"Apt 2");
        expect(postalAddress.locality).to.equal(@"Oakland");
        expect(postalAddress.region).to.equal(@"CA");
        expect(postalAddress.postalCode).to.equal(@"94602");
        expect(postalAddress.countryCodeAlpha2).to.equal(@"US");
    });
});

describe(@"currencyCode", ^{
    it(@"defaults to nil", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        expect(checkout.currencyCode).to.beNil();
    });
    
    it(@"retains the specified currency code override", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        checkout.currencyCode = @"XYZ";
        expect(checkout.currencyCode).to.equal(@"XYZ");
    });
});

SpecEnd

