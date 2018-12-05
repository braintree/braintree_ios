#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
 Number of units of the item purchased. Can include up to 4 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, readonly, strong) NSNumber *quantity;

/**
 Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, readonly, strong) NSNumber *unitAmount;

/**
 Optional: Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, nullable, strong) NSNumber *unitTaxAmount;

/**
 Item name. Maximum 127 characters.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 Optional: Item description. Maximum 127 characters.
 */
@property (nonatomic, nullable, copy) NSString *itemDescription;

/**
 Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
 */
@property (nonatomic, readonly, assign) BTPayPalLineItemKind kind;

/**
 Optional: Product or UPC code for the item. Maximum 127 characters.
 */
@property (nonatomic, nullable, copy) NSString *productCode;

/**
 Total amount of this line item. Can include up to 2 decimal places.
 */
@property (nonatomic, readonly, strong) NSNumber *totalAmount;

/**
 Optional: Discount amount for the line item. Can include up to 2 decimal places. This value can't be negative.
 */
@property (nonatomic, nullable, strong) NSNumber *discountAmount;

/**
 Optional: The unit of measure or the unit of measure code. Maximum 12 characters.
 */
@property (nonatomic, nullable, strong) NSString *unitOfMeasure;

/**
 Optional: Code used to classify items purchased and track the total amount spent across various categories of products and services.
 Different corporate purchasing organizations may use different standards, but the
 [United Nations Standard Products and Services Code (UNSPSC)](https://www.unspsc.org/) is frequently used.
 Maximum 12 characters.
 */
@property (nonatomic, nullable, copy) NSString *commodityCode;

/**
 Optional: Tax amount for the line item. Can include up to 2 decimal places. This value can't be negative.
 */
@property (nonatomic, nullable, strong) NSNumber *taxAmount;

/**
 Optional: The URL to product information.
 */
@property (nonatomic, nullable, strong) NSURL *url;

/**
 Initialize a PayPayLineItem

 @param quantity Number of units of the item purchased. Can include up to 4 decimal places. This value can't be negative or zero.
 @param unitAmount Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.
 @param totalAmount Total amount of this line item. Can include up to 2 decimal places.
 @param name Item name. Maximum 127 characters.
 @param kind Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
 @return A PayPalLineItem.
 */
- (instancetype)initWithQuantity:(NSNumber *)quantity
                      unitAmount:(NSNumber *)unitAmount
                     totalAmount:(NSNumber *)totalAmount
                            name:(NSString *)name
                            kind:(BTPayPalLineItemKind)kind;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithQuantity:unitAmount:name:kind:")));

- (NSDictionary *)requestParameters;

@end

NS_ASSUME_NONNULL_END
