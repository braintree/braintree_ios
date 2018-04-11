#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about an American Express rewards balance.
 */
@interface BTAmericanExpressRewardsBalance : NSObject

/**
 Optional. An error code when there was an issue fetching the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *errorCode;

/**
 Optional. An error message when there was an issue fetching the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *errorMessage;

/**
 Optional. The conversion rate associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *conversionRate;

/**
 Optional. The currency amount associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *currencyAmount;

/**
 Optional. The currency ISO code associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *currencyIsoCode;

/**
 Optional. The request ID used when fetching the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *requestId;

/**
 Optional. The rewards amount associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *rewardsAmount;

/**
 Optional. The rewards unit associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *rewardsUnit;

/**
 Initialize with JSON from Braintree
 */
- (instancetype)initWithJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END

