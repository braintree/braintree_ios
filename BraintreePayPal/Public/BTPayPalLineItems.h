#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTPayPalLineItems : NSObject

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
@property (nonatomic, strong) NSNumber *quantity;

/**
 Per-unit price of the item. Can include up to 4 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, strong) NSDecimalNumber *unitAmount;

/**
 Per-unit tax price of the item. Can include up to 2 decimal places. This value can't be negative or zero.
 */
@property (nonatomic, nullable, strong) NSDecimalNumber *unitTaxAmount;

/**
 Item name. Maximum 35 characters, or 127 characters for PayPal transactions.
 */
@property (nonatomic, copy) NSString *name;

/**
 Item description. Maximum 127 characters.
 */
@property (nonatomic, nullable, copy) NSString *itemDescription;

/**
 Indicates whether the line item is a debit (sale) or credit (refund) to the customer.
 */
@property (nonatomic, assign) BTPayPalLineItemKind kind;

/**
 Product or UPC code for the item. Maximum 12 characters, or 127 characters for PayPal transactions.
 */
@property (nonatomic, nullable, copy) NSString *productCode;

/**
 Quantity x unit amount. Can include up to 2 decimal places.
 */
@property (nonatomic, strong) NSDecimalNumber *totalAmount;

/**
 Discount amount for the line item. Can include up to 2 decimal places. This value can't be negative.
 */
@property (nonatomic, nullable, strong) NSDecimalNumber *discountAmount;

/**
 The unit of measure or the unit of measure code. Maximum 12 characters.
 */
@property (nonatomic, nullable, strong) NSString *unitOfMeasure;

/**
 Code used to classify items purchased and track the total amount spent across various categories of products and services.
 Different corporate purchasing organizations may use different standards, but the
 [United Nations Standard Products and Services Code (UNSPSC)](https://www.unspsc.org/) is frequently used.
 Maximum 12 characters.
 */
@property (nonatomic, nullable, copy) NSString *commodityCode;

/**
 Tax amount for the line item. Can include up to 2 decimal places. This value can't be negative.
 */
@property (nonatomic, nullable, strong) NSDecimalNumber *taxAmount;

/**
 The URL to product information.
 */
@property (nonatomic,nullable, strong) NSURL *url;

@end

NS_ASSUME_NONNULL_END
