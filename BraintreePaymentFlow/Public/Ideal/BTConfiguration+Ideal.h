#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 @brief Category on BTConfiguration for iDEAL
 */
@interface BTConfiguration (Ideal)

/**
 @brief Indicates whether iDEAL is enabled for the merchant account.
 */
@property (nonatomic, readonly, assign) BOOL isIdealEnabled;

/**
 @brief Returns the RouteId used by the iDEAL.
 */
@property (nonatomic, readonly, copy) NSString *routeId;

/**
 @brief The base iDEAL assets URL
 */
@property (nonatomic, readonly, copy) NSString *idealAssetsUrl;

@end
