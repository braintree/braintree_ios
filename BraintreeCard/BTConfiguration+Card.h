#import <BraintreeCore/BTConfiguration.h>

/**
 BTConfiguration category for Card.
 */
@interface BTConfiguration (Card)

/**
 Indicates whether fraud device data collection should occur.
 */
@property (nonatomic, readonly, assign) BOOL collectFraudData;

@end
