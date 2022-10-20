#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@class BTConfiguration;

/**
 BTConfiguration category for Card.
 */
@interface BTConfiguration (Card)

/**
 Indicates whether fraud device data collection should occur.
 */
@property (nonatomic, readonly, assign) BOOL collectFraudData;

@end
