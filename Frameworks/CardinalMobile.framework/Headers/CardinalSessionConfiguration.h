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
 * @constant CardinalSessionEnvironmentSandbox Sandbox Environment
 * @constant CardinalSessionEnvironmentTesting Testing Environment
 * @constant CardinalSessionEnvironmentStaging Staging Environment
 * @constant CardinalSessionEnvironmentProduction Production Environment
 */
typedef NS_ENUM(NSUInteger, CardinalSessionEnvironment) {
    CardinalSessionEnvironmentSandbox,
    CardinalSessionEnvironmentTesting,
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
    CardinalSessionUITypeBoth,
    CardinalSessionUITypeNative,
    CardinalSessionUITypeHTML
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

/*!
 * @const CardinalSessionRenderTypeHTML
 * @brief CardinalSessionRenderType for HTML
 */
extern CardinalSessionRenderType const *CardinalSessionRenderTypeHTML;

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
 * @property timeout Timeout in Milliseconds
 * @brief Sets the default timeout in milliseconds for how long the SDK will wait for a response from a Cardinal server for all operations. See preset values for Standard and Short timeouts.
 * Default value is CardinalSessionTimeoutDEFAULT (about 8 seconds).
 */
@property (nonatomic, assign) NSUInteger timeout;

/*!
 * @property proxyServerURL Proxy Server URL
 * @brief Sets a proxy server through which the Cardinal SDK Session operates.
 * Default value is nil, meaning no proxy server is used.
 */
@property (nonatomic, copy, nullable) NSURL *proxyServerURL;

/*!
 * @property uiType UI Type
 * @brief Sets the Interface type that the device supports for displaying specific challenge user interfaces within the SDK.
 * Default value is CardinalSessionUITypeBoth.
 */
@property (nonatomic, assign) CardinalSessionUIType uiType;

/*!
 * @property enableQuickAuth Enable Quick Authentication
 * @brief Sets enable quick auth.
 * Default value is false.
 */
@property (nonatomic) BOOL enableQuickAuth;

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
 * @property enableDFSync Synchronize Setup Task with Lasso
 * @brief Enable synchronize setup task.
 * Default value is false.
 */
@property (nonatomic) BOOL enableDFSync;

@end

NS_ASSUME_NONNULL_END
