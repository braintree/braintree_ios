#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BTClientApplePayStatusType) {
    BTClientApplePayStatusOff = 0,
    BTClientApplePayStatusMock = 1,
    BTClientApplePayStatusProduction = 2,
};

/// A utility that parses the Apple Pay configuration from the client token.
@interface BTClientApplePayConfiguration : NSObject

/// Initialize an Apple Pay configuration based on a configuration from the client token.
///
/// Expects a dictionary containing two string keys "merchantId" and "status".
///
/// @param dictionary A dictionary represnetation of the Apple Pay configuration.
///
/// @return An initialized configuration object
- (instancetype)initWithConfigurationObject:(id)dictionary NS_DESIGNATED_INITIALIZER;

- (id)init __attribute__((unavailable("Please use initWithConfigurationObject:")));

/// The current Apple Pay status.
///
/// @see BTClientApplePayStatusType
@property (nonatomic, assign, readonly) BTClientApplePayStatusType status;

/// The current Apple Pay merchant id for initializing a PKPaymentRequest
@property (nonatomic, copy, readonly) NSString *merchantId;

@end
