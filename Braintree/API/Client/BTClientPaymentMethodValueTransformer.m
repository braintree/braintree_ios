#import "BTClientPaymentMethodValueTransformer.h"
#import "BTAPIResponseParser.h"
#import "BTMutablePaymentMethod.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"

@implementation BTClientPaymentMethodValueTransformer

+ (Class)transformedValueClass {
    return [BTPaymentMethod class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    BTAPIResponseParser *r = [BTAPIResponseParser parserWithDictionary:value];

    BTPaymentMethod *p;

    NSString *type = [r stringForKey:@"type"];
    if ([type isEqualToString:@"CreditCard"]) {
        BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];

        card.description = [r stringForKey:@"description"];
        card.typeString = [r[@"details"] stringForKey:@"cardType"];
        card.lastTwo = [r[@"details"] stringForKey:@"lastTwo"];
        card.challengeQuestions = [r setForKey:@"securityQuestions"];
        card.nonce = [r stringForKey:@"nonce"];

        p = card;
    } else if ([type isEqualToString:@"PayPalAccount"]) {
        BTMutablePayPalPaymentMethod *payPal = [[BTMutablePayPalPaymentMethod alloc] init];

        payPal.nonce = [r stringForKey:@"nonce"];
        payPal.email = [r[@"details"] stringForKey:@"email"];

        // Braintree gateway has some inconsistent behavior depending on
        // the type of nonce, and sometimes returns "PayPal" for description,
        // and sometimes returns a real identifying string. The former is not
        // desirable for display. The latter is.
        // As a workaround, we ignore descriptions that look like "PayPal".
        id description = [r stringForKey:@"description"];
        if (![[description lowercaseString] isEqualToString:@"paypal"]) {
            payPal.description = description;
        }

        p = payPal;
    } else if ([type isEqualToString:@"ApplePayPayment"]) {
        BTMutableApplePayPaymentMethod *card = [[BTMutableApplePayPaymentMethod alloc] init];

        card.description = [r stringForKey:@"description"];
        card.challengeQuestions = [r setForKey:@"securityQuestions"];
        card.nonce = [r stringForKey:@"nonce"];

        p = card;
    } else {
        BTMutablePaymentMethod *paymentMethod = [[BTMutablePaymentMethod alloc] init];

        paymentMethod.nonce = [r stringForKey:@"nonce"];
        paymentMethod.description = [r stringForKey:@"nonce"];
        paymentMethod.challengeQuestions = [r setForKey:@"securityQuestions"];

        p = paymentMethod;
    }
    
    return p;
}

@end
