@import AddressBook;

#import "BTApplePayPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"

SpecBegin(BTApplePayPaymentMethod)

__block BTApplePayPaymentMethod *immutable;

beforeEach(^{
    ABRecordRef address;
    BTMutableApplePayPaymentMethod *applePayPaymentMethod = [[BTMutableApplePayPaymentMethod alloc] init];
    applePayPaymentMethod.nonce = @"a nonce";
    address = ABPersonCreate();
    applePayPaymentMethod.shippingAddress = address;
    CFRelease(address);
    address = ABPersonCreate();
    applePayPaymentMethod.billingAddress = address;
    CFRelease(address);
    PKContact *billingContact = [[PKContact alloc] init];
    billingContact.emailAddress = @"billing_email@example.com";
    PKContact *shippingContact = [[PKContact alloc] init];
    shippingContact.emailAddress = @"shipping_email.example.com";
    applePayPaymentMethod.billingContact = billingContact;
    applePayPaymentMethod.shippingContact = shippingContact;
    immutable = [applePayPaymentMethod copy];
});

describe(@"mutableCopy", ^{
    it(@"returns a BTMutableApplyPayPaymentMethod", ^{
        id copy = [immutable mutableCopy];
        expect(copy).to.beKindOf([BTMutableApplePayPaymentMethod class]);
    });

    it(@"retains the shipping address", ^{
        NSInteger referenceCount = CFGetRetainCount(immutable.shippingAddress);
        BTApplePayPaymentMethod *copy = [immutable mutableCopy];
        expect(copy.shippingAddress).to.equal(immutable.shippingAddress);
        expect(CFGetRetainCount(copy.shippingAddress)).to.equal(referenceCount + 1);
    });

    it(@"retains the billing address", ^{
        NSInteger referenceCount = CFGetRetainCount(immutable.shippingAddress);
        BTApplePayPaymentMethod *copy = [immutable mutableCopy];
        expect(copy.shippingAddress).to.equal(immutable.shippingAddress);
        expect(CFGetRetainCount(copy.billingAddress)).to.equal(referenceCount + 1);
    });
    
    it(@"copies the shipping contact", ^{
        BTApplePayPaymentMethod *copy = [immutable mutableCopy];
        expect(copy.shippingContact).to.equal(immutable.shippingContact);
    });
    
    it(@"copies the billing contact", ^{
        BTApplePayPaymentMethod *copy = [immutable mutableCopy];
        expect(copy.billingContact).to.equal(immutable.billingContact);
    });
});

describe(@"copy", ^{
    it(@"returns a BTApplyPayPaymentMethod", ^{
        id copy = [immutable copy];
        expect(copy).to.beKindOf([BTApplePayPaymentMethod class]);
    });

    it(@"retains the shipping address", ^{
        NSInteger referenceCount = CFGetRetainCount(immutable.shippingAddress);
        BTApplePayPaymentMethod *copy = [immutable copy];
        expect(copy.shippingAddress).to.equal(immutable.shippingAddress);
        expect(CFGetRetainCount(copy.shippingAddress)).to.equal(referenceCount + 1);
    });

    it(@"retains the billing address", ^{
        NSInteger referenceCount = CFGetRetainCount(immutable.shippingAddress);
        BTApplePayPaymentMethod *copy = [immutable copy];
        expect(copy.shippingAddress).to.equal(immutable.shippingAddress);
        expect(CFGetRetainCount(copy.billingAddress)).to.equal(referenceCount + 1);
    });
    
    it(@"copies the shipping contact", ^{
        BTApplePayPaymentMethod *copy = [immutable copy];
        expect(copy.shippingContact).to.equal(immutable.shippingContact);
    });
    
    it(@"copies the billing contact", ^{
        BTApplePayPaymentMethod *copy = [immutable copy];
        expect(copy.billingContact).to.equal(immutable.billingContact);
    });
});

SpecEnd

SpecBegin(BTMutableApplePayPaymentMethod)

__block BTMutableApplePayPaymentMethod *mutable;

beforeEach(^{
    mutable = [[BTMutableApplePayPaymentMethod alloc] init];
    mutable.nonce = @"a-nonce";
});

describe(@"mutableCopy", ^{
    it(@"returns a BTMutableApplyPayPaymentMethod", ^{
        BTApplePayPaymentMethod *copy = [mutable mutableCopy];
        expect(copy).to.beKindOf([BTMutableApplePayPaymentMethod class]);
        expect(copy.nonce).to.equal(@"a-nonce");
    });
});

describe(@"copy", ^{
    it(@"returns a BTApplyPayPaymentMethod", ^{
        BTApplePayPaymentMethod *copy = [mutable copy];
        expect(copy).to.beKindOf([BTApplePayPaymentMethod class]);
        expect(copy.nonce).to.equal(@"a-nonce");
    });
});


describe(@"nonce", ^{
    it(@"is readonly", ^{
        expect(mutable).to.respondTo(@selector(setNonce:));
        mutable.nonce = @"xxx";
        expect(mutable.nonce).to.equal(@"xxx");
    });
});

SpecEnd
