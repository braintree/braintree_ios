#import "BraintreeDemoCreditCardEntryViewController.h"

@interface BraintreeDemoCreditCardEntryViewController ()<BTUICardFormViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *successOutputTextView;

@end

@implementation BraintreeDemoCreditCardEntryViewController

- (void)cardFormViewDidChange:(BTUICardFormView *)cardFormView {
    if (cardFormView.valid) {
        self.successOutputTextView.text = [NSString stringWithFormat:
                                           @"😍 YOU DID IT \n"
                                            "Number:     %@\n"
                                            "Expiration: %@/%@\n"
                                            "CVV:        %@\n"
                                            "Postal:     %@",
                                           cardFormView.number,
                                           cardFormView.expirationMonth,
                                           cardFormView.expirationYear,
                                           cardFormView.cvv,
                                           cardFormView.postalCode];
    } else {
        self.successOutputTextView.text = @"INVALID 🐴";
    }
}
- (IBAction)toggleCVV:(__unused id)sender {
    self.cardFormView.optionalFields = self.cardFormView.optionalFields ^ BTUICardFormOptionalFieldsCvv;
}
- (IBAction)togglePostalCode:(__unused id)sender {
    self.cardFormView.optionalFields = self.cardFormView.optionalFields ^ BTUICardFormOptionalFieldsPostalCode;
}
- (IBAction)toggleVibrate:(UISwitch *)sender {
    self.cardFormView.vibrate = sender.on;
}

@end
