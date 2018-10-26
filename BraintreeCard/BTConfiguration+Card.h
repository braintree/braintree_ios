#if __has_include("BraintreeCore.h")
#import "BTConfiguration.h"
#else
#import <BraintreeCore/BTConfiguration.h>
#endif

/**
 BTConfiguration category for Card.
 */
@interface BTConfiguration (Card)

/**
 Indicates whether fraud device data collection should occur.
 */
@property (nonatomic, readonly, assign) BOOL collectFraudData;

@end
