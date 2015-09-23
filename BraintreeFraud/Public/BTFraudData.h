#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTFraudDataEnvironment) {
    BTFraudDataEnvironmentDevelopment,
    BTFraudDataEnvironmentQA,
    BTFraudDataEnvironmentSandbox,
    BTFraudDataEnvironmentProduction
};

NS_ASSUME_NONNULL_BEGIN

@interface BTFraudData : NSObject

/// Initializes a `BTFraudData` instance for an environment.
///
/// @param environment The desired environment to target. This setting will determine which
/// default collectorURL is used when collecting fraud data from the device.
- (instancetype)initWithEnvironment:(BTFraudDataEnvironment)environment;


/// Generates a new PayPal fraud ID (i.e. PayPalOneTouchCore `clientMetadataID`) if PayPal is integrated, otherwise returns `nil`
///
/// @return A PayPal fraud ID
+ (nullable NSString *)payPalFraudID;


/// Collects device data using the default merchant ID and collector URL.
///
/// This should be used when the user is paying with a card.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished. It
///                        returns fraud data to send to your server when successful, or an error when it fails.
- (void)collectCardFraudData:(nullable void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;


/// Collects device data using your own merchant ID and a custom collector URL.
///
/// This should be used when the user is paying with a card.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished. It
///                        returns fraud data to send to your server when successful, or an error when it fails.
- (void)collectCardFraudDataWithMerchantID:(NSString *)merchantID
                              collectorURL:(NSString *)collectorURL
                                completion:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;


/// Collects ALL device data using Kount and PayPal, uses the default merchant ID and collector URL for Kount.
///
/// @warning This method collects device data using both Kount and PayPal and has been marked as deprecated
///          in favor of using `-collectCardFraudData:` and `+payPalFraudID` for collecting fraud data for
///          card and PayPal transactions, respectively. If your integration is unable to determine the
///          underlying type of payment option for a transaction (i.e. card or PayPal) -- for example, if
///          your server-side integration stores vaulted payment method tokens without knowing whether it's
///          a tokenized card or a tokenized PayPal account authorization -- you can use this method to gather
///          both. However, using this method for other cases is discouraged, since it creates unnecessary
///          storage overhead for the fraud detection backend services.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished. It
///                        returns fraud data to send to your server when successful, or an error when it fails.
- (void)collectFraudData:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock DEPRECATED_MSG_ATTRIBUTE("Use collectCardFraudData: or payPalFraudID");


/// Collects ALL device data using Kount and PayPal, using your own merchant ID and collector URL for Kount.
///
/// @warning This method collects device data using both Kount and PayPal and has been marked as deprecated
///          in favor of using `-collectCardFraudData:` and `+payPalFraudID` for collecting fraud data for
///          card and PayPal transactions, respectively. If your integration is unable to determine the
///          underlying type of payment option for a transaction (i.e. card or PayPal) -- for example, if
///          your server-side integration stores vaulted payment method tokens without knowing whether it's
///          a tokenized card or a tokenized PayPal account authorization -- you can use this method to gather
///          both. However, using this method for other cases is discouraged, since it creates unnecessary
///          storage overhead for the fraud detection backend services.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished. It
///                        returns fraud data to send to your server when successful, or an error when it fails.
- (void)collectFraudDataWithMerchantID:(NSString *)merchantID
                          collectorURL:(NSString *)collectorURL
                            completion:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock DEPRECATED_MSG_ATTRIBUTE("Use collectCardFraudData: or payPalFraudID");

@end

NS_ASSUME_NONNULL_END
