#import "BraintreeDemoCardHintViewController.h"

#import "BTUICardHint.h"

@interface BraintreeDemoCardHintViewController ()
@property (weak, nonatomic) IBOutlet BTUICardHint *cardHintView;
@property (weak, nonatomic) IBOutlet BTUICardHint *smallCardHintView;
@end

@implementation BraintreeDemoCardHintViewController

- (IBAction)selectedCardType:(UISegmentedControl *)sender {
    BTUIPaymentMethodType type = BTUIPaymentMethodTypeUnknown;
    switch(sender.selectedSegmentIndex) {
        case 0:
            type = BTUIPaymentMethodTypeUnknown;
            break;
        case 1:
            type = BTUIPaymentMethodTypeVisa;
            break;
        case 2:
            type = BTUIPaymentMethodTypeMasterCard;
            break;
        case 3:
            type = BTUIPaymentMethodTypeAMEX;
            break;
        case 4:
            type = BTUIPaymentMethodTypeDiscover;
            break;
    }
    [self.cardHintView setCardType:type animated:YES];
    [self.smallCardHintView setCardType:type animated:YES];
}

- (IBAction)selectedHintMode:(UISegmentedControl *)sender {
    [self.cardHintView setDisplayMode:(sender.selectedSegmentIndex == 0 ? BTCardHintDisplayModeCardType : BTCardHintDisplayModeCVVHint) animated:YES];
    [self.smallCardHintView setDisplayMode:(sender.selectedSegmentIndex == 0 ? BTCardHintDisplayModeCardType : BTCardHintDisplayModeCVVHint) animated:YES];
}

@end
