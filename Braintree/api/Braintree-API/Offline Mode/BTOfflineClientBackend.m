#import "BTOfflineClientBackend.h"

@interface BTOfflineClientBackend ()

@property (nonatomic, strong) NSMutableArray *paymentMethods;

@end

@implementation BTOfflineClientBackend

- (instancetype)init {
    self = [super init];
    if (self) {
        self.paymentMethods = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)allPaymentMethods {
    return self.paymentMethods;
}

- (void)addPaymentMethod:(BTPaymentMethod *)card {
    if (card) {
        [self.paymentMethods insertObject:card atIndex:0];
    }
}

@end
