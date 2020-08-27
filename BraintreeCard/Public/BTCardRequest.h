#import <Foundation/Foundation.h>
@class BTCard;

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about a card to tokenize
 */
@interface BTCardRequest : NSObject

/**
 Initialize with an instance of `BTCard`.
 
 @param card The `BTCard` to initialize with.
 */
- (instancetype)initWithCard:(BTCard *)card;

/**
 The `BTCard` associated with this instance.
 */
@property (nonatomic, strong) BTCard *card;

#pragma mark - UnionPay properties

/**
 The mobile phone number to use to verify the enrollment via SMS.
*/
@property (nonatomic, copy, nullable) NSString *mobilePhoneNumber;

/**
 The country code for the mobile phone number. This string should only contain digits.
 @note By default, this is set to 62.
*/
@property (nonatomic, copy, nullable) NSString *mobileCountryCode;

/**
 The enrollment verification code sent via SMS to the mobile phone number. The code is needed to tokenize a UnionPay card that requires enrollment.
*/
@property (nonatomic, copy, nullable) NSString *smsCode;

/**
 The UnionPay enrollment ID
*/
@property (nonatomic, copy, nullable) NSString *enrollmentID;

@end

NS_ASSUME_NONNULL_END
