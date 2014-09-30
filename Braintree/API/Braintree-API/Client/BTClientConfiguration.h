@import Foundation;

#import "BTClientApplePayConfiguration.h"

#import "BTAPIResource.h"

@interface BTClientConfiguration : NSObject

/// Apple Pay Configuration if Apple Pay is enabled, nil if Apple Pay is disabled
@property (nonatomic, strong) BTClientApplePayConfiguration *applePayConfiguration;

@end
