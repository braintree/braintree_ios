#import <Braintree/BTUI.h>

SpecBegin(BTUI)

describe(@"BTUI", ^{
    it(@"has a braintree theme", ^{
        BTUI *theme = [BTUI braintreeTheme];
        expect(theme.callToActionColor).notTo.beNil();
    });
});

SpecEnd