#import "BraintreeDemoBraintreeInitializationDemoViewController.h"

#import <Braintree/Braintree.h>

#import "BraintreeDemoMerchantAPI.h"

@interface BraintreeDemoBraintreeInitializationDemoViewController ()
@property (nonatomic, copy) void (^completionBlock)(Braintree *braintree, NSString *merchantName, NSError *error);
@end

@implementation BraintreeDemoBraintreeInitializationDemoViewController

- (instancetype)initWithCompletion:(void (^)(Braintree *, NSString *, NSError *))completionBlock {
    self = [self init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}


#pragma mark Demo Steps


@end
