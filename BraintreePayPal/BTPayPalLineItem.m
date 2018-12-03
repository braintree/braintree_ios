#import "BTPayPalLineItem.h"

@implementation BTPayPalLineItem

- (instancetype)initWithQuantity:(NSNumber *)quantity
                      unitAmount:(NSDecimalNumber *)unitAmount
                            name:(NSString *)name
                            kind:(BTPayPalLineItemKind)kind {
    self = [super init];
    if (self) {
        _quantity = quantity;
        _unitAmount = unitAmount;
        _name = name;
        _kind = kind;
    }

    return self;
}

@end
