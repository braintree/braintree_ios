#import "BTPayPalLineItem.h"

@implementation BTPayPalLineItem

- (instancetype)initWithQuantity:(NSNumber *)quantity
                      unitAmount:(NSNumber *)unitAmount
                     totalAmount:(NSNumber *)totalAmount
                            name:(NSString *)name
                            kind:(BTPayPalLineItemKind)kind {
    self = [super init];
    if (self) {
        _quantity = quantity;
        _unitAmount = unitAmount;
        _totalAmount = totalAmount;
        _name = name;
        _kind = kind;
    }

    return self;
}

- (NSDictionary *)requestParameters {
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    requestParameters[@"quantity"] = self.quantity;
    requestParameters[@"unit_amount"] = self.unitAmount.stringValue;
    requestParameters[@"total_amount"] = self.totalAmount.stringValue;
    requestParameters[@"name"] = self.name;
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
    if (self.unitTaxAmount) {
        requestParameters[@"unit_tax_amount"] = self.unitTaxAmount.stringValue;
    }
    if (self.taxAmount) {
        requestParameters[@"tax_amount"] = self.taxAmount.stringValue;
    }
    if (self.discountAmount) {
        requestParameters[@"discount_amount"] = self.discountAmount.stringValue;
    }
    if (self.itemDescription) {
        requestParameters[@"description"] = self.itemDescription;
    }
    if (self.productCode) {
        requestParameters[@"product_code"] = self.productCode;
    }
    if (self.unitOfMeasure) {
        requestParameters[@"unit_of_measure"] = self.unitOfMeasure;
    }
    if (self.commodityCode) {
        requestParameters[@"commodity_code"] = self.commodityCode;
    }
    if (self.url) {
        requestParameters[@"url"] = self.url.absoluteString;
    }

    return [requestParameters copy];
}

@end
