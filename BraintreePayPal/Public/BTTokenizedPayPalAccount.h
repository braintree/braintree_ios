#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedPayPalAccount : NSObject <BTTokenized>

/// Email address associated with the PayPal Account.
@property (nonatomic, readonly, copy) NSString *email;

/// Optional. The billing address.
/// Will be provided if you request "address" scope when using -[PayPalDriver startAuthorizationWithAdditionalScopes:completion:]
@property (nonatomic, BT_NULLABLE, readonly, strong) BTPostalAddress *accountAddress;

/// Client Metadata Id associated with this transaction.
@property (nonatomic, readonly, copy) NSString *clientMetadataId;

@end

BT_ASSUME_NONNULL_END
