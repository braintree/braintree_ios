#import <Foundation/Foundation.h>

/**
 Contains information about a PayPal credit amount
 */
@interface BTPayPalCreditFinancingAmount: NSObject

/**
 3 letter currency code as defined by <a href="http://www.iso.org/iso/home/standards/currency_codes.htm">ISO 4217</a>.
 */
@property (nonatomic, nullable, readonly, copy) NSString *currency;

/**
 An amount defined by <a href="http://www.iso.org/iso/home/standards/currency_codes.htm">ISO 4217</a> for the given currency.
 */
@property (nonatomic, nullable, readonly, copy) NSString *value;

@end
