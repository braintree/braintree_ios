#import "BTPayPalLineItem.h"

@implementation BTPayPalLineItem

- (instancetype)initWithQuantity:(NSNumber *)quantity
                      unitAmount:(NSNumber *)unitAmount
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

- (NSDictionary *)requestParameters {
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    requestParameters[@"quantity"] = self.quantity.stringValue;
    requestParameters[@"unit_amount"] = self.unitAmount.stringValue;
    if (self.unitTaxAmount) {
        requestParameters[@"unit_tax_amount"] = self.unitTaxAmount.stringValue;
    }
    requestParameters[@"name"] = self.name;
    if (self.itemDescription) {
        requestParameters[@"description"] = self.itemDescription;
    }
    NSString *kindString;
    switch (self.kind) {
        case BTPayPalLineItemKindDebit:
            kindString = @"debit";
            break;
        case BTPayPalLineItemKindCredit:
            kindString = @"credit";
            break;
    }
    requestParameters[@"kind"] = kindString;
    if (self.productCode) {
        requestParameters[@"product_code"] = self.productCode;
    }
    requestParameters[@"total_amount"] = self.totalAmount.stringValue;
    if (self.discountAmount) {
        requestParameters[@"discount_amount"] = self.discountAmount.stringValue;
    }
    if (self.unitOfMeasure) {
        requestParameters[@"unit_of_measure"] = self.unitOfMeasure;
    }
    if (self.commodityCode) {
        requestParameters[@"commodity_code"] = self.commodityCode;
    }
    if (self.taxAmount) {
        requestParameters[@"tax_amount"] = self.taxAmount.stringValue;
    }
    if (self.url) {
        requestParameters[@"url"] = self.url.absoluteString;
    }

    return [requestParameters copy];
}

- (NSNumber *)totalAmount {
    return @(self.quantity.integerValue * self.unitAmount.doubleValue);
}

@end
