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
            [system presentViewControllerWithClass:[BTUICardFormViewSpecCardEntryViewController class]
  withinNavigationControllerWithNavigationBarClass:nil
                                      toolbarClass:nil
                                configurationBlock:nil];
            [tester tapViewWithAccessibilityLabel:@"Card Number"];
            [tester enterTextIntoCurrentFirstResponder:@"4111111111111111"];
            [tester waitForFirstResponderWithAccessibilityLabel:@"MM/YY"];

        });
    });

    describe(@"retreat on backspace", ^{
        it(@"retreats on backspace and deletes one digit", ^{
            [system presentViewControllerWithClass:[BTUICardFormViewSpecCardEntryViewController class]
  withinNavigationControllerWithNavigationBarClass:nil
                                      toolbarClass:nil
                                configurationBlock:nil];
            [tester tapViewWithAccessibilityLabel:@"Card Number"];
            [tester enterTextIntoCurrentFirstResponder:@"4111111111111111"];
            [tester enterTextIntoCurrentFirstResponder:@"\b"];
            [tester waitForFirstResponderWithAccessibilityLabel:@"Card Number"];
            [tester waitForViewWithAccessibilityLabel:@"Card Number" value:@"411111111111111" traits:0];
        });
    });

    describe(@"setting the form programmatically", ^{
        __block BTUICardFormView *cardFormView = [[BTUICardFormView alloc] init];
        
        describe(@"card number", ^{
            it(@"sets the field text", ^{
                [cardFormView setNumber:@"411111"];
                [system presentView:cardFormView];
                [tester waitForViewWithAccessibilityLabel:@"Card Number" value:@"411111" traits:0];
            });
            
            describe(@"truncation", ^{
                context(@"when card type is known", ^{
                    it(@"uses card type max digits", ^{
                        [cardFormView setNumber:@"411111111111111111111111"];
                        [system presentView:cardFormView];
                        [tester waitForViewWithAccessibilityLabel:@"Card Number" value:@"4111111111111111" traits:0];
                    });
                });
                
                context(@"when card type is unknown", ^{
                    it(@"uses max digits for all cards", ^{
                        [cardFormView setNumber:@"00000000000000000000000000000"];

                        [system presentView:cardFormView];
                        
                        NSUInteger maxLength = [BTUICardType maxNumberLength];
                        NSMutableString *expectedCardNumber = [NSMutableString new];
                        for (int i = 0; i < maxLength; i++) {
                            [expectedCardNumber appendString:@"0"];
                        }
                        [tester waitForViewWithAccessibilityLabel:@"Card Number" value:expectedCardNumber traits:0];
                    });
                });
            });
        });
    });
});

SpecEnd
