@import Foundation;

#import "BTPaymentMethod.h"

@interface BTCoinbasePaymentMethod : BTPaymentMethod

@property (nonatomic, readonly, copy) NSString *userIdentifier;

@end
