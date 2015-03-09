#import "BTCoinbase.h"

SpecBegin(BTCoinbaseAcceptance)

describe(@"Coinbase authorization", ^{
    beforeAll(^{
        [tester waitForViewWithAccessibilityLabel:@"dcpspy2brwdjr3qn"];
        [tester tapViewWithAccessibilityLabel:@"Payment Buttons"];
        [tester tapViewWithAccessibilityLabel:@"Choose Integration Technique"];
        [tester tapViewWithAccessibilityLabel:@"BTUICoinbaseButton"];
    });

    it(@"authorizes the user in the coinbase app and returns a nonce when the app is available", ^{
        id mockSharedApplication = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
        [[[mockSharedApplication stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", @"com.coinbase.oauth-authorize")];

        [system waitForApplicationToOpenURLWithScheme:@"com.coinbase.oauth-authorize"
                                  whileExecutingBlock:^{
                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];
                                  } returning:YES];

        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake-coinbase-auth-code"];
        [[UIApplication sharedApplication] openURL:returnURL];

        [tester waitForViewWithAccessibilityLabel:@"Got a ฿ nonce! satoshi@example.com"];
    });

    it(@"shows the error when the coinbase flow results in an error", ^{
        id mockSharedApplication = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
        [[[mockSharedApplication stub] andReturnValue:@YES] canOpenURL:HC_hasProperty(@"scheme", @"com.coinbase.oauth-authorize")];

        [system waitForApplicationToOpenURLWithScheme:@"com.coinbase.oauth-authorize"
                                  whileExecutingBlock:^{
                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];
                                  } returning:YES];

        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?error=access_denied&error_description=The+resource+owner+or+authorization+server+denied+the+request."];
        [[UIApplication sharedApplication] openURL:returnURL];

        [tester waitForViewWithAccessibilityLabel:@"Error"];
        [tester waitForViewWithAccessibilityLabel:@"The resource owner or authorization server denied the request."];
        [tester tapViewWithAccessibilityLabel:@"OK"];
        [tester waitForViewWithAccessibilityLabel:@"An error occurred"];
    });

    it(@"authorizes the user in the browser and returns a nonce when the app is not available", ^{
        [system waitForApplicationToOpenURLWithScheme:@"https"
                                  whileExecutingBlock:^{
                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];
                                  } returning:YES];

        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake-coinbase-auth-code"];
        [[UIApplication sharedApplication] openURL:returnURL];

        [tester waitForViewWithAccessibilityLabel:@"Got a ฿ nonce! satoshi@example.com"];
    });
});

SpecEnd
