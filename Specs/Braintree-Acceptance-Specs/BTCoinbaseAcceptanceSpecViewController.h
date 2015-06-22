#import <UIKit/UIKit.h>
#import "BTPaymentProvider.h"

extern NSString *const BTCoinbaseAcceptanceSpecCoinbaseScheme;

/// A view controller for testing out coinbase app switching, intended to be used only in
/// BTCoinbaseAcceptanceSpec
@interface BTCoinbaseAcceptanceSpecViewController : UIViewController <BTPaymentMethodCreationDelegate>
@property (nonatomic, strong) BTPaymentProvider *provider;
@property (nonatomic, strong) UILabel *statusLabel;
@end

