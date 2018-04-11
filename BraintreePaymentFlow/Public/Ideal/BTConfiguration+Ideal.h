#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 Category on BTConfiguration for iDEAL
 */
@interface BTConfiguration (Ideal)

/**
 Indicates whether iDEAL is enabled for the merchant account.
 */
@property (nonatomic, readonly, assign) BOOL isIdealEnabled;

/**
 Returns the RouteId used by the iDEAL.
 */
@property (nonatomic, readonly, copy) NSString *routeId;

/**
 The base iDEAL assets URL
 */
@property (nonatomic, readonly, copy) NSString *idealAssetsUrl;

@end
