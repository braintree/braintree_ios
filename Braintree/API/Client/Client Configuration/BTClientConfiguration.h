@import Foundation;

#import "BTClientApplePayConfiguration.h"

@class BTClientToken;

@interface BTClientConfiguration : NSObject

- (instancetype)initWithClientToken:(BTClientToken *)clientToken NS_DESIGNATED_INITIALIZER;

/// Apple Pay Configuration if Apple Pay is enabled, nil if Apple Pay is disabled
@property (nonatomic, strong) BTClientApplePayConfiguration *applePayConfiguration;

@end
