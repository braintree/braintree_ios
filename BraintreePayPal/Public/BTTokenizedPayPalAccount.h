#import <Foundation/Foundation.h>
#import "BTPostalAddress.h"
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedPayPalAccount : NSObject <BTTokenized>

/// Email address associated with the PayPal Account.
@property (nonatomic, readonly, copy) NSString *email;

/// Optional. The billing address.
/// Will be provided if you request "address" scope when using -[PayPalDriver startAuthorizationWithAdditionalScopes:completion:]
@property (nonatomic, BT_NULLABLE, readonly, strong) BTPostalAddress *accountAddress;

@end

BT_ASSUME_NONNULL_END
