#import <KIF/KIF.h>
#import "BraintreeDemoCreditCardEntryViewController.h"

SpecBegin(BTUICardFormView)

describe(@"Card Form", ^{
    describe(@"accepting and validating credit card details", ^{
        it(@"accepts a number, an expiry, a cvv and a postal code", ^{
            BraintreeDemoCreditCardEntryViewController *vc = [[BraintreeDemoCreditCardEntryViewController alloc] init];
            [system presentViewController:vc
withinNavigationControllerWithNavigationBarClass:nil
                             toolbarClass:nil
                       configurationBlock:nil];

            [tester enterText:@"4111111111111111" intoViewWithAccessibilityLabel:@"Card Number"];
            [tester tapViewWithAccessibilityLabel:@"MM/YY"];
            [tester enterTextIntoCurrentFirstResponder:@"122018"];
            [tester enterText:@"100" intoViewWithAccessibilityLabel:@"CVV"];
            [tester enterText:@"60606" intoViewWithAccessibilityLabel:@"Postal Code"];

            expect(vc.cardFormView.valid).to.beTruthy();
        });
    });

    describe(@"auto advancing", ^{
        it(@"auto advances from field to field", ^{
            [system presentViewControllerWithClass:[BraintreeDemoCreditCardEntryViewController class]
  withinNavigationControllerWithNavigationBarClass:nil
                                      toolbarClass:nil
                                configurationBlock:nil];
            [tester tapViewWithAccessibilityLabel:@"Card Number"];
            [tester enterTextIntoCurrentFirstResponder:@"4111111111111111"];
            [tester waitForFirstResponderWithAccessibilityLabel:@"MM/YY"];

        });
    });

    describe(@"retreat on backspace", ^{
        it(@"retreats on backspace", ^{
            [system presentViewControllerWithClass:[BraintreeDemoCreditCardEntryViewController class]
  withinNavigationControllerWithNavigationBarClass:nil
                                      toolbarClass:nil
                                configurationBlock:nil];
            [tester tapViewWithAccessibilityLabel:@"Card Number"];
            [tester enterTextIntoCurrentFirstResponder:@"4111111111111111"];
            [tester enterTextIntoCurrentFirstResponder:@"\b"];
            [tester waitForFirstResponderWithAccessibilityLabel:@"Card Number"];
        });
    });
});

SpecEnd
