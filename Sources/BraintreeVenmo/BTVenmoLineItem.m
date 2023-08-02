#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoLineItem.h>
#else
#import <BraintreeVenmo/BTVenmoLineItem.h>
#endif

@implementation BTVenmoLineItem

- (instancetype)initWithQuantity:(NSInteger *)quantity
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
    requestParameters[@"quantity"] = [NSNumber numberWithInteger:*(self.quantity)];
    requestParameters[@"unit_amount"] = self.unitAmount;
    requestParameters[@"name"] = self.name;

    NSString *kindString;
    switch (self.kind) {
        case BTVenmoLineItemKindDebit:
            kindString = @"debit";
            break;
        case BTVenmoLineItemKindCredit:
            kindString = @"credit";
            break;
    }

    requestParameters[@"kind"] = kindString;
    if (self.unitTaxAmount) {
        requestParameters[@"unit_tax_amount"] = self.unitTaxAmount;
    }
    if (self.itemDescription) {
        requestParameters[@"description"] = self.itemDescription;
    }
    if (self.productCode) {
        requestParameters[@"product_code"] = self.productCode;
    }
    if (self.url) {
        requestParameters[@"url"] = self.url.absoluteString;
    }

    return [requestParameters copy];
}


@end
