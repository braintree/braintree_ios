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
        expect(checkout.enableShippingAddress).to.beFalsy();
        expect(checkout.shippingAddress).to.beNil();
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

describe(@"enableShippingAddress", ^{
    it(@"retains the shipping address preference", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        checkout.enableShippingAddress = YES;
        expect(checkout.enableShippingAddress).to.beTruthy();
    });
});

describe(@"shippingAddress", ^{
    it(@"retains the specified shipping address override", ^{
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber one]];
        ABRecordRef person = ABPersonCreate();
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge_retained CFStringRef)@"Johnny", NULL);
        ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge_retained CFStringRef)@"Appleseed", NULL);

        ABMutableMultiValueRef shippingAddress = ABMultiValueCreateMutable(kABDictionaryPropertyType);
        ABMultiValueAddValueAndLabel(shippingAddress, (__bridge CFDictionaryRef)@{
                                                                                  (__bridge_transfer NSString *)kABPersonAddressStreetKey: @"1 Infinite Loop",
                                                                                  (__bridge_transfer NSString *)kABPersonAddressCityKey: @"Cupertino",
                                                                                  (__bridge_transfer NSString *)kABPersonAddressStateKey: @"CA",
                                                                                  (__bridge_transfer NSString *)kABPersonAddressZIPKey: @"95014",
                                                                                  (__bridge_transfer NSString *)kABPersonAddressCountryKey: @"USA",
                                                                                  }, kABHomeLabel, NULL);
        ABRecordSetValue(person, kABPersonAddressProperty, shippingAddress, NULL);
        CFRelease(shippingAddress);

        ABMultiValueRef emailsMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailsMultiValue, @"test@example.com", kABHomeLabel, NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailsMultiValue, NULL);
        CFRelease(emailsMultiValue);
        
        NSInteger retainCount = CFGetRetainCount(person);
        checkout.shippingAddress = person;
        expect(CFGetRetainCount(person)).to.equal(retainCount + 1);
        expect((__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)).to.equal(@"Johnny");
        ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
        expect((__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, 0)).to.equal(@"test@example.com");
        CFRelease(multiValue);
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

