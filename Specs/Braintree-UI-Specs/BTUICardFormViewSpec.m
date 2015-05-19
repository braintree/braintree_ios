#import <Braintree/BTUICardFormView.h>
#import "BTUICardType.h"
#import <KIF/KIF.h>
#import <PureLayout/PureLayout.h>

@interface BTUICardFormViewSpecCardEntryViewController : UIViewController
@property (nonatomic, strong) BTUICardFormView *cardFormView;
@end

@implementation BTUICardFormViewSpecCardEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardFormView = [[BTUICardFormView alloc] initWithFrame:self.view.frame];

    [self.view addSubview:self.cardFormView];

    [self.cardFormView autoPinEdgeToSuperviewMargin:ALEdgeLeading];
    [self.cardFormView autoPinEdgeToSuperviewMargin:ALEdgeTrailing];
    [self.cardFormView autoPinToTopLayoutGuideOfViewController:self withInset:10];
}

@end

SpecBegin(BTUICardFormView)

describe(@"Card Form", ^{
    describe(@"accepting and validating credit card details", ^{
        it(@"accepts a number, an expiry, a cvv and a postal code", ^{
            BTUICardFormViewSpecCardEntryViewController *viewController = [[BTUICardFormViewSpecCardEntryViewController alloc] init];
            
            [system presentViewController:viewController];

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
            [system presentViewController:[[BTUICardFormViewSpecCardEntryViewController alloc] init]];
            [tester tapViewWithAccessibilityLabel:@"Card Number"];
            [tester enterTextIntoCurrentFirstResponder:@"4111111111111111"];
            [tester waitForFirstResponderWithAccessibilityLabel:@"MM/YY"];
        });
    });

    describe(@"retreat on backspace", ^{
        it(@"retreats on backspace and deletes one digit", ^{
            [system presentViewController:[[BTUICardFormViewSpecCardEntryViewController alloc] init]];
            [tester tapViewWithAccessibilityLabel:@"Card Number"];
            [tester enterTextIntoCurrentFirstResponder:@"4111111111111111"];
            [tester enterTextIntoCurrentFirstResponder:@"\b"];
            [tester waitForFirstResponderWithAccessibilityLabel:@"Card Number"];
            [tester waitForViewWithAccessibilityLabel:@"Card Number" value:@"411111111111111" traits:0];
        });
    });

    describe(@"setting the form programmatically", ^{
        __block BTUICardFormView *cardFormView;

        beforeEach(^{
            cardFormView = [[BTUICardFormView alloc] init];
        });
        
        describe(@"card number field", ^{
            it(@"sets the field text", ^{
                cardFormView.number = @"411111";
                [system presentView:cardFormView];
                [tester waitForViewWithAccessibilityLabel:@"Card Number" value:@"411111" traits:0];
            });
            
            describe(@"truncation", ^{
                context(@"when card type is known", ^{
                    it(@"uses card type max digits", ^{
                        cardFormView.number = @"411111111111111111111111";
                        [system presentView:cardFormView];
                        [tester waitForViewWithAccessibilityLabel:@"Card Number" value:@"4111111111111111" traits:0];
                    });
                });
                
                context(@"when card type is unknown", ^{
                    it(@"uses max digits for all cards", ^{
                        cardFormView.number = @"00000000000000000000000000000";

                        [system presentView:cardFormView];
                        
                        NSString *expectedCardNumber = [@"" stringByPaddingToLength:[BTUICardType maxNumberLength] withString:@"0" startingAtIndex:0];
                        [tester waitForViewWithAccessibilityLabel:@"Card Number" value:expectedCardNumber traits:0];
                    });
                });
            });
        });

        describe(@"expiry field", ^{
            it(@"accepts a date", ^{
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                dateComponents.month = 1;
                dateComponents.year = 2016;
                dateComponents.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

                NSDate *date = [dateComponents date];
                [cardFormView setExpirationDate:date];
                [system presentView:cardFormView];
                [[tester usingTimeout:1] waitForViewWithAccessibilityLabel:@"01/2016"];
            });

            it(@"can be set when visible", ^{
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                dateComponents.month = 1;
                dateComponents.year = 2016;
                dateComponents.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDate *date = [dateComponents date];

                [system presentView:cardFormView];
                [cardFormView setExpirationDate:date];
                [[tester usingTimeout:1] waitForViewWithAccessibilityLabel:@"01/2016"];
            });
        });
    });
});

SpecEnd
