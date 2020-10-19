//
//  CardinalSessionConfiguration.h
//  CardinalMobileSDK
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UiCustomization.h"
NS_ASSUME_NONNULL_BEGIN

/*!
 * @typedef CardinalSessionEnvironment
 * @brief List of CardinalSession Enviroments
 * @constant CardinalSessionEnvironmentStaging Staging Environment
 * @constant CardinalSessionEnvironmentProduction Production Environment
 */
typedef NS_ENUM(NSUInteger, CardinalSessionEnvironment) {
    CardinalSessionEnvironmentStaging,
    CardinalSessionEnvironmentProduction
};

/*!
 * @typedef CardinalSessionUIType
 * @brief List of CardinalSession UI Types
 * @constant CardinalSessionUITypeBoth Support for both Native and HTML
 * @constant CardinalSessionUITypeNative Support for Native UI Type
 * @constant CardinalSessionUITypeHTML Support for HTML UI Type
 */
typedef NS_ENUM(NSUInteger, CardinalSessionUIType) {
    CardinalSessionUITypeNative,
#if TARGET_OS_IOS
    CardinalSessionUITypeHTML,
    CardinalSessionUITypeBoth
#endif 
};

/*!
 * @typedef CardinalSessionRenderType
 * @brief NSString that represents different RenderTypes
 */
typedef NSString CardinalSessionRenderType;

/*!
 * @typedef CardinalSessionRenderTypeArray
 * @brief NSArray of type CardinalSessionRenderType for holding all the RenderTyper supported
 */
typedef NSArray<const CardinalSessionRenderType *> CardinalSessionRenderTypeArray;

/*!
 * @const CardinalSessionRenderTypeOTP
 * @brief CardinalSessionRenderType for OTP
 */
extern CardinalSessionRenderType const *CardinalSessionRenderTypeOTP;

/*!
 * @const CardinalSessionRenderTypeSingleSelect
 * @brief CardinalSessionRenderType for Single Select
 */
extern CardinalSessionRenderType const *CardinalSessionRenderTypeSingleSelect;

/*!
 * @const CardinalSessionRenderTypeMultiSelect
 * @brief CardinalSessionRenderType for Multi Select
 */
extern CardinalSessionRenderType const *CardinalSessionRenderTypeMultiSelect;

/*!
 * @const CardinalSessionRenderTypeOOB
 * @brief CardinalSessionRenderType for OOB
 */
extern CardinalSessionRenderType const *CardinalSessionRenderTypeOOB;

#if TARGET_OS_IOS
/*!
 * @const CardinalSessionRenderTypeHTML
 * @brief CardinalSessionRenderType for HTML
 */
extern CardinalSessionRenderType const *CardinalSessionRenderTypeHTML;
#endif

/*!
 * @const CardinalSessionEnvironmentDEFAULT
 * @brief CardinalSessionEnvironment constant that represents the Default Environment based on the Build
 * In Debug builds, evaluates to .sandbox; In Release builds, evaluates to .production.
 */
extern const CardinalSessionEnvironment CardinalSessionEnvironmentDEFAULT;

/*!
 * @const CardinalSessionTimeoutStandard
 * @brief Standard Timeout for Cardinal Session. About 8 second.
 */
extern NSUInteger const CardinalSessionTimeoutStandard;

/*!
 * @const CardinalSessionTimeoutShort
 * @brief Short Timeout for Cardinal Session. About 1 second.
 */
extern NSUInteger const CardinalSessionTimeoutShort;
/// Evaluates to Standard timeout value (about 8 seconds)
extern NSUInteger const CardinalSessionTimeoutDEFAULT;

/*!
 * @interface CardinalSessionConfiguration Session Configuration
 * @brief Various Configurations for CardinalSession
 */
@interface CardinalSessionConfiguration : NSObject <NSCopying>

/*!
 * @property deploymentEnvironment Deployment Environment
 * @brief Sets the server the Cardinal SDK Session will communicate with.
 * See CardinalSessionEnvironment. Default value is CardinalSessionEnvironmentProduction.
 */
@property (nonatomic, assign) CardinalSessionEnvironment deploymentEnvironment;

/*!
 * @property requestTimeout Timeout in Milliseconds
 * @brief Sets the default timeout in milliseconds for how long the SDK will wait for a response from a Cardinal server for all operations. See preset values for Standard and Short timeouts.
 * Default value is CardinalSessionTimeoutDEFAULT (about 8 seconds).
 */
@property (nonatomic, assign) NSUInteger requestTimeout;


/*!
 * @property timeout Challenge Screen Timeout in Minutes.
 * @brief Sets the time in Minute before how long the SDK Challenge Screen will timeout. Minimum timeout is 5 minutes.
 * Default value is 5 minutes.
 */
@property (nonatomic, assign) NSUInteger challengeTimeout;

/*!
 * @property proxyServerURL Proxy Server URL
 * @brief Sets a proxy server through which the Cardinal SDK Session operates.
 * Default value is nil, meaning no proxy server is used.
 */
@property (nonatomic, copy, nullable) NSURL *proxyServerURL;

#if TARGET_OS_IOS
/*!
 * @property uiType UI Type
 * @brief Sets the Interface type that the device supports for displaying specific challenge user interfaces within the SDK.
 * Default value is CardinalSessionUITypeBoth.
 */
@property (nonatomic, assign) CardinalSessionUIType uiType;
#elif TARGET_OS_TV
/*!
* @property uiType UI Type
* @brief The Interface type that the device supports for displaying specific challenge user interfaces within the SDK.
* Default value is CardinalSessionUITypeNative.
*/
@property (nonatomic, assign, readonly) CardinalSessionUIType uiType;
#endif
/*!
 * @property enableQuickAuth Enable Quick Authentication
 * @brief Sets enable quick auth. This property is deprecated in v2.2.4. This feature will no longer be supported in the SDK.
 * Default value is false.
 */
@property (nonatomic) BOOL enableQuickAuth DEPRECATED_ATTRIBUTE;

/*!
 * @property renderType Render Type
 * @brief Sets RenderTypes that the device supports for displaying specific challenge user interfaces within the SDK.
 * Default value is false.
 */
@property (nonatomic, copy) CardinalSessionRenderTypeArray *renderType;

/*!
 * @property uiCustomization UI Customization of Challenge Views
 * @brief Set the customization of different UITypes for Challege Views.
 * Default value is nil.
 */
@property (nonatomic, strong) UiCustomization *uiCustomization;

/*!
 * @property darkModeUiCustomization UI Customization of Dark Mode Challenge Views
 * @brief Set the customization of different UITypes for Dark Mode Challege Views.
 * Default value is nil.
 */
@property (nonatomic, strong) UiCustomization *darkModeUiCustomization;

/*!
 * @property enableDFSync Synchronize Setup Task with Lasso
 * @brief Enable synchronize setup task.
 * Default value is true.
 */
@property (nonatomic) BOOL enableDFSync;

/*!
 * @property threeDSRequestorAppURL Three DS Requester APP URL
 * @brief Merchant app declaring their URL within the CReq message so that the Authentication app can call the Merchant app after OOB authentication has occurred. Each transaction would require a unique Transaction ID by using the SDK Transaction ID.
 */
@property (nonatomic, copy, nullable) NSString *threeDSRequestorAppURL;

/*!
 * @property collectLogs Collect Logs
 * @brief Collect and send logs for each transaction.
 * Default value is true.
 */
@property (nonatomic) BOOL collectLogs;
@end

NS_ASSUME_NONNULL_END
