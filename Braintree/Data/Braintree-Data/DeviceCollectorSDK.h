//
//  DeviceCollectorSDK.h
//  Device Collector SDK for iOS
//
//  Copyright (c) 2012 Kount. All rights reserved.
//


//////////////////////////////////////////////////////////////////////////////
// Your application must link with the UIKit and SystemConfiguration
// frameworks to use the SDK successfully.
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Error Codes sent by [DeviceCollectorSDKDelegate onCollectorError]
//
// NSError trapped. See error for details
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
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Protocol which will provide status updates from a DeviceCollectorSDK
// instance.
//
@protocol DeviceCollectorSDKDelegate <NSObject>
@optional

  ////////////////////////////////////////////////////////////////////////////
  // Notification that the collector has started.
- (void) onCollectorStart;

  ////////////////////////////////////////////////////////////////////////////
  // Notfication that the collector finished successfully.
- (void) onCollectorSuccess;

  ////////////////////////////////////////////////////////////////////////////
  // Notification that an error occurred.
  //
  // @param errorCode Error code
  // @param error Triggering error if available
- (void) onCollectorError:(int)errorCode :(NSError*)error;
@end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Device Collector wrapper object.
//
@interface DeviceCollectorSDK : NSObject <UIWebViewDelegate>

  ////////////////////////////////////////////////////////////////////////////
  // Initialize collector instance.
  //
  // @param debugLogging Enable/disable logging of debugging messages
- (DeviceCollectorSDK*) initWithDebugOn:(bool)debugLogging;

  ////////////////////////////////////////////////////////////////////////////
  // Set the URL that the Device Collector will use.
  //
  // @param url Full URL to device collector 302-redirect page
- (void) setCollectorUrl:(NSString*)url;

  ////////////////////////////////////////////////////////////////////////////
  // Set your Merchant Id.
  //
  // @param merc Merchant Id
- (void) setMerchantId:(NSString*)merc;

  ////////////////////////////////////////////////////////////////////////////
  // Collect device information for the given session.
  //
  // @param sessionId Unique session id
- (void) collect:(NSString*)sessionId;

  ////////////////////////////////////////////////////////////////////////////
  // Set a DeviceCollectorSDKDelegate to notify about collector events.
  //
  // @param delegate Object to notify
- (void) setDelegate:(id<DeviceCollectorSDKDelegate>)delegate;

@end
//////////////////////////////////////////////////////////////////////////////
