#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoLineItem.h>
#else
#import <BraintreeVenmo/BTVenmoLineItem.h>
#endif

@implementation BTVenmoLineItem

- (instancetype)initWithQuantity:(NSNumber *)quantity
                      unitAmount:(NSString *)unitAmount
                            name:(NSString *)name
                            kind:(BTVenmoLineItemKind)kind {
    self = [super init];
    if (self) {
        _quantity = quantity;
        _unitAmount = unitAmount;
        _name = name;
        _kind = kind;
    }

    return self;
}

- (NSDictionary *)requestParameters {
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    requestParameters[@"quantity"] = self.quantity;
    requestParameters[@"unitAmount"] = self.unitAmount;
    requestParameters[@"name"] = self.name;

    NSString *kindString;

    switch (self.kind) {
        case BTVenmoLineItemKindDebit:
            kindString = @"DEBIT";
            break;
        case BTVenmoLineItemKindCredit:
            kindString = @"CREDIT";
            break;
    }

    requestParameters[@"type"] = kindString;

    if (self.unitTaxAmount) {
        requestParameters[@"unitTaxAmount"] = self.unitTaxAmount;
    }
    if (self.itemDescription) {
        requestParameters[@"description"] = self.itemDescription;
    }
    if (self.productCode) {
        requestParameters[@"productCode"] = self.productCode;
    }
    if (self.url && self.url != [NSURL URLWithString:@""]) {
        requestParameters[@"url"] = self.url.absoluteString;
    }

    return [requestParameters copy];
}

@end
