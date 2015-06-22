#import "BTPayPalPaymentMethod.h"
#import "BTPaymentMethod_Mutable.h"

@interface BTPayPalPaymentMethod ()

- (void)setEmail:(NSString *)email;

@property (nonatomic, readwrite, strong) NSDictionary *additionalInfo;

@end
