#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTAmericanExpressRewardsBalance : NSObject

/**
 @brief Optional. An error code when there was an issue fetching the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *errorCode;

/**
 @brief Optional. An error message when there was an issue fetching the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *errorMessage;

/**
 @brief Optional. The conversion rate associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *conversionRate;

/**
 @brief Optional. The currency amount associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *currencyAmount;

/**
 @brief Optional. The currency ISO code associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *currencyIsoCode;

/**
 @brief Optional. The request ID used when fetching the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *requestId;

/**
 @brief Optional. The rewards amount associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *rewardsAmount;

/**
 @brief Optional. The rewards unit associated with the rewards balance
 */
@property (nonatomic, nullable, copy) NSString *rewardsUnit;

/**
 @brief Initialize with JSON from Braintree
 */
- (instancetype)initWithJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END

