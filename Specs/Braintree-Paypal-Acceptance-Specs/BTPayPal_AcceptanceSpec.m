SpecBegin(BTPayPal_Acceptance)

describe(@"The Braintree PayPal button", ^{
    describe(@"login flow", ^{
        it(@"displays the PayPal delegate login flow and results in the button displaying details about the logged in user", ^{
            // Tap PayPal Button
            [tester tapViewWithAccessibilityLabel:@"Pay with PayPal"];

            // Navigate around log in screen
            [tester tapViewWithAccessibilityLabel:@"Email" traits:UIAccessibilityTraitButton];
            [tester tapViewWithAccessibilityLabel:@"Phone" traits:UIAccessibilityTraitButton];
            [tester tapViewWithAccessibilityLabel:@"Email" traits:UIAccessibilityTraitButton];

            // Type in credentials
            [tester enterTextIntoCurrentFirstResponder:@"test@example.com"];
            [tester enterTextIntoCurrentFirstResponder:@"\n"];
            [tester enterTextIntoCurrentFirstResponder:@"password1"];

            // Log in
            [tester tapViewWithAccessibilityLabel:@"Log In" traits:UIAccessibilityTraitButton];

            // View Authorization Screen
            [tester waitForViewWithAccessibilityLabel:@"Offline Test Merchant"];

            // Take a look at terms to verify we are in a future payments flow
            [tester tapViewWithAccessibilityLabel:@"PayPal account"];
            [tester waitForViewWithAccessibilityLabel:@"Future Payment Agreement"];
            [tester tapViewWithAccessibilityLabel:@"Back"];

            // Agree to future payment terms
            [tester tapViewWithAccessibilityLabel:@"Agree"];

            [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Agree"];

            [tester waitForViewWithAccessibilityLabel:@"email@example.com"];
        });
    });

    it(@"displays the original button when canceled", ^{
        [tester tapViewWithAccessibilityLabel:@"Pay with PayPal"];
        [tester waitForViewWithAccessibilityLabel:@"Email"];
        [tester tapViewWithAccessibilityLabel:@"Cancel"];
        [tester waitForViewWithAccessibilityLabel:@"Pay with PayPal"];
    });
});

SpecEnd
