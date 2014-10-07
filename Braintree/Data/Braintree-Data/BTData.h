#import "DeviceCollectorSDK.h"
#import "BTClient.h"

// Error Codes sent to btData:didFailWithErrorCode:error:.
//
// NSError trapped. See error for details
#define BT_DC_ERR_NSERROR              DC_ERR_NSERROR
// Network access not available
#define BT_DC_ERR_NONETWORK            DC_ERR_NONETWORK
// Invalid collector URL
#define BT_DC_ERR_INVALID_URL          DC_ERR_INVALID_URL
// Invalid Kount Merchant Id
#define BT_DC_ERR_INVALID_MERCHANT     DC_ERR_INVALID_MERCHANT
// Invalid Kount Session Id
#define BT_DC_ERR_INVALID_SESSION      DC_ERR_INVALID_SESSION
// Device collection failed
#define BT_DC_ERR_VALIDATION_FAILURE   DC_ERR_VALIDATION_FAILURE

typedef NS_ENUM(NSInteger, BTDataEnvironment) {
    BTDataEnvironmentDevelopment,
    BTDataEnvironmentQA,
    BTDataEnvironmentSandbox,
    BTDataEnvironmentProduction
};

@protocol BTDataDelegate;

/// BT Data - Braintree's advanced fraud protection solution
@interface BTData : NSObject

/// Set a BTDataDelegate to receive notifications about collector events.
///
/// @param delegate Object to notify
@property (nonatomic, weak) id<BTDataDelegate> delegate;

/// Initialize a BTData instance for use alongside an existing BTClient instance
///
/// @note BTData cannot currently read the Kount environment from BTClient. In the future, we will replace
///       this method with a simpler `initWithClient:`.
///
/// @param client       A BTClient instance
/// @param environment  The Braintree Kount configuration
- (instancetype)initWithClient:(BTClient *)client environment:(BTDataEnvironment)environment NS_DESIGNATED_INITIALIZER;

/// Collect fraud data for the current session.
///
/// @return an opaque string of the device data that can be passed into server-side calls, such as Transaction.create.
- (NSString *)collectDeviceData;


#pragma mark Direct Integrations

/// Set your fraud merchant id.
///
/// @note If you do not call this method, a generic Braintree value will be used.
///
/// @param fraudMerchantId The fraudMerchantId you have established with your Braintree account manager.
- (void)setFraudMerchantId:(NSString *)fraudMerchantId;

/// Set the URL that the Device Collector will use.
///
/// @note If you do not call this method, a generic Braintree value will be used.
///
/// @param url Full URL to device collector 302-redirect page
- (void)setCollectorUrl:(NSString *)url;


#pragma mark Deprecated Methods

/// Initialize collector instance.
///
/// @param debugLogging Enable/disable logging of debugging messages
- (instancetype)initWithDebugOn:(BOOL)debugLogging DEPRECATED_MSG_ATTRIBUTE("Please use initWithClient:environment:");

/// Returns a pre-configured instance of BTData that uses Braintree's shared
/// merchant id and Braintree's shared collector URL.
/// This is the suggested default if you do not have a custom Kount configuration.
/// Contact Braintree support for more information about advanced fraud protection.
///
/// @return a preconfigured instance of BTData
+ (instancetype)defaultDataForEnvironment:(BTDataEnvironment)environment delegate:(id<BTDataDelegate>)delegate DEPRECATED_MSG_ATTRIBUTE("Please use initWithClient:environment:");

/// Collect device information for a session with a randomly
/// generated session identifier.
/// @return the newly constructed Kount session id
- (NSString *)collect DEPRECATED_MSG_ATTRIBUTE("Please use the collectDeviceData method instead");

/// Collect device information for the given session.
///
/// @param sessionId Unique session id
- (void)collect:(NSString*)sessionId DEPRECATED_MSG_ATTRIBUTE("Please use the collectDeviceData method instead");


/// Set your Merchant Id.
///
/// @param merc Kount Merchant Id
- (void)setKountMerchantId:(NSString *)merc DEPRECATED_MSG_ATTRIBUTE("Please use setFraudMerchantId instead");

@end

/// Protocol that provides status updates from BTData
@protocol BTDataDelegate <NSObject>
@optional

/// Notification that the collector has started.
- (void)btDataDidStartCollectingData:(BTData *)data;

/// Notfication that the collector finished successfully.
- (void)btDataDidComplete:(BTData *)data;

/// Notification that an error occurred.
///
/// @param errorCode Error code (See BT_DC_* above)
/// @param error Triggering error if available
- (void)btData:(BTData *)data didFailWithErrorCode:(int)errorCode error:(NSError *)error;

@end
