#import <KIF/KIF.h>
#import "BraintreeDemoCreditCardEntryViewController.h"

SpecBegin(BTUICardFormView)

describe(@"Card Form", ^{
    describe(@"accepting and validating credit card details", ^{
        it(@"accepts a number, an expiry, a cvv and a postal code", ^{
            BraintreeDemoCreditCardEntryViewController *viewController = [[BraintreeDemoCreditCardEntryViewController alloc] init];

            [system runBlock:^KIFTestStepResult(NSError **error) {
                UIViewController *viewControllerToPresent = viewController;
                KIFTestCondition(viewControllerToPresent != nil, error, @"Expected a view controller, but got nil");
                
                Class navigationBarClassToUse = system.defaultNavigationBarClass;
                Class toolbarClassToUse = system.defaultToolbarClass;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:navigationBarClassToUse toolbarClass:toolbarClassToUse];
                navigationController.viewControllers = @[viewControllerToPresent];
                [UIApplication sharedApplication].keyWindow.rootViewController = navigationController;
                
                return KIFTestStepResultSuccess;
            }];

            [tester enterText:@"4111111111111111" intoViewWithAccessibilityLabel:@"Card Number"];
            [tester tapViewWithAccessibilityLabel:@"MM/YY"];
            [tester enterTextIntoCurrentFirstResponder:@"122018"];
            [tester enterText:@"100" intoViewWithAccessibilityLabel:@"CVV"];
            [tester enterText:@"60606" intoViewWithAccessibilityLabel:@"Postal Code"];

            expect(viewController.cardFormView.valid).to.beTruthy();
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
