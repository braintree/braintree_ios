#import <Foundation/Foundation.h>

@class BTPaymentMethod;

@interface BTOfflineClientBackend : NSObject

- (instancetype)init;
- (NSArray *)allPaymentMethods;
- (void)addPaymentMethod:(BTPaymentMethod *)card;

@end
