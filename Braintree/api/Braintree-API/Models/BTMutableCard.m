#import "BTMutableCard.h"

@implementation BTMutableCard

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BTCardTypeUnknown;
    }
    return self;
}


@end
