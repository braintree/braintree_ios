#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Generic postal address
 */
@interface BTPostalAddress : NSObject <NSCopying>

/**
 Optional. Recipient name for shipping address.
*/
@property (nonatomic, nullable, copy) NSString *recipientName;

/**
 Line 1 of the Address (eg. number, street, etc).
*/
@property (nonatomic, nullable, copy) NSString *streetAddress;

/**
 Optional line 2 of the Address (eg. suite, apt #, etc.).
*/
@property (nonatomic, nullable, copy) NSString *extendedAddress;

/**
 City name
*/
@property (nonatomic, nullable, copy) NSString *locality;

/**
 2 letter country code.
*/
@property (nonatomic, nullable, copy) NSString *countryCodeAlpha2;

/**
 Zip code or equivalent is usually required for countries that have them. For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code.
*/
@property (nonatomic, nullable, copy) NSString *postalCode;

/**
 2 letter code for US states, and the equivalent for other countries.
*/
@property (nonatomic, nullable, copy) NSString *region;

@end

NS_ASSUME_NONNULL_END
