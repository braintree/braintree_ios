#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A PayPal line item to be displayed in the PayPal checkout flow.
 */
@interface BTPayPalLineItem : NSObject

/**
 Use this option to specify whether a line item is a debit (sale) or credit (refund) to the customer.
 */
typedef NS_ENUM(NSInteger, BTPayPalLineItemKind) {
    /// Debit
    BTPayPalLineItemKindDebit = 1,

    /// Credit
    BTPayPalLineItemKindCredit,
};

/**
 Number of units of the item purchased. This value must be a whole number and can't be negative or zero.
 */
@property (nonatomic, readonly, copy) NSString *quantity;

/**
 Per-unit price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, readonly, copy) NSString *unitAmount;

/**
 Item name. Maximum 127 characters.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
 */
@property (nonatomic, readonly, assign) BTPayPalLineItemKind kind;

/**
 Optional: Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, nullable, copy) NSString *unitTaxAmount;

/**
 Optional: Item description. Maximum 127 characters.
 */
@property (nonatomic, nullable, copy) NSString *itemDescription;

/**
 Optional: Product or UPC code for the item. Maximum 127 characters.
 */
@property (nonatomic, nullable, copy) NSString *productCode;

/**
 Optional: The URL to product information.
 */
@property (nonatomic, nullable, strong) NSURL *url;

/**
 Initialize a PayPayLineItem

 @param quantity Number of units of the item purchased. Can include up to 4 decimal places. This value can't be negative or zero.
 @param unitAmount Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.
 @param name Item name. Maximum 127 characters.
 @param kind Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
 @return A PayPalLineItem.
 */
- (instancetype)initWithQuantity:(NSString *)quantity
                      unitAmount:(NSString *)unitAmount
                            name:(NSString *)name
                            kind:(BTPayPalLineItemKind)kind;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithQuantity:unitAmount:name:kind:")));

/**
 Returns the line item in a dictionary.

 @return A dictionary with the line item information formatted for a request.
 */
- (NSDictionary *)requestParameters;

@end

NS_ASSUME_NONNULL_END
