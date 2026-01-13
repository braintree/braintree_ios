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
 * @typedef CardinalRenderType
 * @brief List of Cardinal Render Types
 * @constant CardinalRenderTypeBoth Support for both Native and HTML
 * @constant CardinalRenderTypeNative Support for Native Render Type
 * @constant CardinalRenderTypeHTML Support for HTML Render Type
 */
typedef NS_ENUM(NSUInteger, CardinalRenderType) {
    CardinalRenderTypeNative,
#if TARGET_OS_IOS
    CardinalRenderTypeHTML,
    CardinalRenderTypeBoth
#endif
};

/*
* @typedef CardinalDatacenter
* @brief List of CardinalDatacenter
* @constant CARDINAL CCAUrls
* @constant VISA VISAUrls
*/
typedef enum CardinalDatacenter {
   Cardinal,
   Visa
} CardinalDatacenter;

/*!
 * @typedef CardinalUiType
 * @brief NSString that represents different UiTypes
 */
typedef NSString CardinalUiType;

/*!
 * @typedef CardinalUiTypeArray
 * @brief NSArray of type CardinalUiType for holding all the UiType supported
 */

typedef NSArray<const CardinalUiType *> CardinalUiTypeArray;

/*!
 * @const CardinalUiTypeOTP
 * @brief CardinalUiType for OTP
 */
extern CardinalUiType const *CardinalUiTypeOTP;

/*!
 * @const CardinalUiTypeSingleSelect
 * @brief CardinalUiType for Single Select
 */
extern CardinalUiType const *CardinalUiTypeSingleSelect;

/*!
 * @const CardinalUiTypeMultiSelect
 * @brief CardinalUiType for Multi Select
 */
extern CardinalUiType const *CardinalUiTypeMultiSelect;

/*!
 * @const CardinalUiTypeOOB
 * @brief CardinalUiType for OOB
 */
extern CardinalUiType const *CardinalUiTypeOOB;

#if TARGET_OS_IOS
/*!
 * @const CardinalUiTypeHTML
 * @brief CardinalUiType for HTML
 */
extern CardinalUiType const *CardinalUiTypeHTML;
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
#if DEBUG
#define kCCAConfigChallengeTimeoutInMinuteMIN 0
#else
#define kCCAConfigChallengeTimeoutInMinuteMIN 5
#endif


/*!
 * @property deploymentEnvironment Deployment Environment
 * @brief Sets the server the Cardinal SDK Session will communicate with.
 * See CardinalSessionEnvironment. Default value is CardinalSessionEnvironmentProduction.
 */
@property (nonatomic, assign) CardinalSessionEnvironment deploymentEnvironment;

/*!
 * @property timeout Challenge Screen Timeout in Minutes.
 * @brief Sets the time in Minute before how long the SDK Challenge Screen will timeout. Minimum timeout is 5 minutes.
 * Default value is 5 minutes.
 */
@property (nonatomic, assign) NSUInteger sdkMaxTimeout;

/*!
 * @property proxyServerURL Proxy Server URL
 * @brief Sets a proxy server through which the Cardinal SDK Session operates.
 * Default value is nil, meaning no proxy server is used.
 */
@property (nonatomic, copy, nullable) NSURL *proxyServerURL;

#if TARGET_OS_IOS
/*!
 * @property renderType Render Type
 * @brief Sets the Render type that the device supports for displaying specific challenge user interfaces within the SDK.
 * Default value is CardinalRenderTypeBoth.
 */
@property (nonatomic, assign) CardinalRenderType renderType;
#elif TARGET_OS_TV
/*!
* @property renderType Render Type
* @brief Sets RenderTypes that the device supports for displaying specific challenge user interfaces within the SDK.
* Default value is CardinalSessionRenderTypeNative.
*/
@property (nonatomic, assign, readonly) CardinalRenderType renderType;
#endif

/*!
 * @property uiType UI Type
 * @brief Sets the Interface type that the device supports for displaying specific challenge user interfaces within the SDK.
 * Default value is false.
 */
@property (nonatomic, copy) CardinalUiTypeArray *uiType;

/*!
 * @property uiCustomization UI Customization of Challenge Views
 * @brief Set the customization of different UITypes for Challege Views.
 * Default value is nil.
 */
@property (nonatomic, strong) UiCustomization *uiCustomization;

/*!
 * @property darkUiCustomization UI Customization of Dark Mode Challenge Views
 * @brief Set the customization of different UITypes for Dark Mode Challege Views.
 * Default value is nil.
 */
@property (nonatomic, strong) UiCustomization *darkUiCustomization;

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

/*!
 * @property cardBrand Card Brand
 * @brief Retrieve certificates with the card brand the merchant submits.
 */
@property (nonatomic) NSString* cardBrand;

/*!
 * @property messageVersion Message Version
 * @brief Protocol version identifier This shall be the Protocol Version Number of the specification utilised by the system creating this message.
 */
@property (nonatomic) NSString* messageVersion;

/*!
 * @property ephemeralKeyPair Ephemeral Key
 * @brief Public key component of the ephemeral key pair generated by the ACS and used to establish session keys between the 3DS SDK and the ACS.
 */
@property (nonatomic) NSString* ephemeralKeyPair;

/*!
 * @property cardinalDatacenter CCA Database
 * @brief Cardinal urls and Visa DC urls
 */
@property (nonatomic, assign) CardinalDatacenter cardinalDatacenter;
@end

NS_ASSUME_NONNULL_END
