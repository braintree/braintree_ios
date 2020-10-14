#if SWIFT_PACKAGE
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
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
