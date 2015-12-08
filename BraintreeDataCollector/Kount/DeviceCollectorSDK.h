/**
 * @abstract Device Collector SDK for iOS
 * @discussion This SDK is used to implement the Device Collector in your
 * application.  Please read through all the documentation before implementing.
 *
 * Copyright (c) 2012-2015 Kount. All rights reserved.
 */

/**
 * @warning *Important* Your application must link with the *UIKit*, 
 * *SystemConfiguration*, *AdSupport* and *CoreLocation* frameworks to use the 
 * SDK successfully.
 */
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AdSupport/AdSupport.h>

/** @name Error Codes */

/**
 * Error Codes sent by [DeviceCollectorSDKDelegate onCollectorError]
 */

//NSError trapped. See error for details
#define DC_ERR_NSERROR              1
// Network access not available
#define DC_ERR_NONETWORK            2
// Invalid collector URL
#define DC_ERR_INVALID_URL          3
// Invalid Merchant Id
#define DC_ERR_INVALID_MERCHANT     4
// Invalid Session Id
#define DC_ERR_INVALID_SESSION      5
// Device collection failed
#define DC_ERR_VALIDATION_FAILURE   6

/**
 * Optional Collectors.  These are enabled by default, but you can
 * pass these values into *skipList* and they will be skipped.
 */

// Geo Location Collector
#define DC_COLLECTOR_GEO_LOCATION   @"COLLECTOR_GEO_LOCATION"

/** 
 * @protocol DeviceCollectorSDKDelegate
 * @abstract Protocol which will provide status updates from a 
 * DeviceCollectorSDK instance.
 *
 */
@protocol DeviceCollectorSDKDelegate <NSObject>
@optional

/**
 * @method onCollectorStart
 * @abstract Notification that the collector has started.
 * @result void
 */
- (void) onCollectorStart;
  
/**
 * @method onCollectorSuccess
 * @abstract Notification that the collector finished successfully.
 * @result void
 */
- (void) onCollectorSuccess;

/**
 * @method onCollectorError
 * @abstract Notification that an error occurred.
 *
 *  @param errorCode Error code
 *  @param error Triggering error if available
 *  @result void
 */
- (void) onCollectorError:(int) errorCode
                withError:(NSError*) error;
@end // end @protocol DeviceCollectorSDKDelegate

/**
 * @class DeviceCollectorSDK
 * @abstract Device Collector wrapper object.
 */
@interface DeviceCollectorSDK : NSObject <UIWebViewDelegate>
/**
 * @method skipList
 * @abstract A list of collectors to skip
 * @param list An NSArray of DC_COLLECTOR_* define values
 * @result void
 */
@property (nonatomic, strong) NSArray *skipList;

/**
 * @method initWithDebugOn
 * @abstract Initialize collector instance.
 *
 * @param debugLogging Enable/disable logging of debugging messages
 * @result A new instance of DeviceCollectorSDK
 */
- (DeviceCollectorSDK*) initWithDebugOn:(bool) debugLogging;

/**
 * @method setCollectorUrl
 * @abstract Set the URL that the Device Collector will use.
 * @discussion This is required PRIOR to calling: method 
 * [DeviceCollectorSDK collect]
 * @param url Full URL to device collector 302-redirect page
 * @result void
 */
- (void) setCollectorUrl:(NSString*) url;

/**
 * @method setMerchantId
 * @abstract Set your Merchant Id.
 * @discussion This is required PRIOR to calling: method 
 * [DeviceCollectorSDK collect]
 * @param merc Merchant Id
 * @result void
 */
- (void) setMerchantId:(NSString*) merc;

/**
 * @method collect
 * @abstract Collect device information for the given session.
 * @discussion You must set the merchantID and collectorURL prior to
 * calling this method using [DeviceCollectorSDK setMerchantId] and 
 * [DeviceCollectorSDK setCollectorUrl]. Optionally you can set the delegate 
 * prior to calling collect if you want to get status updates: 
 * [DeviceCollectorSDK setDelegate]
 * @param sessionId Unique session id
 * @result void
 */
- (void) collect:(NSString*) sessionId;

/**
 * @method setDelegate
 * @abstract Set a DeviceCollectorSDKDelegate to notify about collector 
 * events.
 *
 * @param delegate Object to notify
 * @result void
 */
- (void) setDelegate:(id<DeviceCollectorSDKDelegate>) delegate;
@end // end @interface DeviceCollectorSDK