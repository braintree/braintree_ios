#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTPayPalApprovalRequest : NSObject

/**
 Get token from approval URL
*/
+ (nullable NSString *)tokenFromApprovalURL:(nonnull NSURL *)approvalURL;

/**
 All requests MUST include the app's Client ID, as obtained from developer.paypal.com
*/
@property (nonnull, nonatomic) NSString *clientID;

/**
 All requests MUST indicate the environment -
 `PayPalEnvironmentProduction`, `PayPalEnvironmentMock`, or `PayPalEnvironmentSandbox`;
 or else a stage indicated as `base-url:port`
*/
@property (nonnull, nonatomic) NSString *environment;

/**
 All requests MUST indicate the URL scheme to be used for returning to this app, following a browser switch
*/
@property (nonnull, nonatomic) NSString *callbackURLScheme;

/**
 Requests MAY include additional key/value pairs that One Touch will add to the payload
 (For example, the Braintree client_token, which is required by the temporary Braintree Future Payments consent webpage.)
*/
@property (nonnull, nonatomic, strong) NSDictionary *additionalPayloadAttributes;

@property (nonnull, nonatomic, strong) NSString *pairingId;

/**
 Client has already created a payment on PayPal server; this is the resulting HATEOS ApprovalURL
*/
@property (nonnull, nonatomic) NSURL *approvalURL;

#ifdef DEBUG
/**
 DEBUG-only: don't use downloaded configuration file; defaults to NO
*/
@property (nonatomic, assign) BOOL useHardcodedConfiguration;
#endif

@end

NS_ASSUME_NONNULL_END
