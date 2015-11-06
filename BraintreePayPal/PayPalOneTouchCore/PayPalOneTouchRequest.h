//
//  PayPalOneTouchRequest.h
//
//  Version 3.2.2
//
//  Copyright (c) 2015 PayPal Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayPalOneTouchCoreResult.h"

/// Completion block for receiving the result of preflighting a request
typedef void (^PayPalOneTouchRequestPreflightCompletionBlock) (PayPalOneTouchRequestTarget target);

/// Adapter block for app switching.
typedef void (^PayPalOneTouchRequestAdapterBlock) (BOOL success, NSURL *url, PayPalOneTouchRequestTarget target, NSString *clientMetadataId, NSError *error);

/// This environment MUST be used for App Store submissions.
extern NSString *const PayPalEnvironmentProduction;
/// Sandbox: Uses the PayPal sandbox for transactions. Useful for development.
extern NSString *const PayPalEnvironmentSandbox;
/// Mock: Mock mode. Does not submit transactions to PayPal. Fakes successful responses. Useful for unit tests.
extern NSString *const PayPalEnvironmentMock;

/// Base class for all OneTouch requests
@interface PayPalOneTouchRequest : NSObject

/// Optional preflight method, to determine in advance to which app we will switch when
/// this request's performWithCompletionBlock: method is called.
///
/// @return PayPalOneTouchRequestTargetBrowser, PayPalOneTouchRequestTargetOnDeviceApplication, or
///         PayPalOneTouchRequestTargetNone
///
/// @note As currently implemented, completionBlock will be called immediately.
///       We use a completion block here to allow for future changes in implementation that might cause
///       delays (such as time-consuming cryptographic operations, or server interactions).
- (void)getTargetApp:(PayPalOneTouchRequestPreflightCompletionBlock)completionBlock;

/// Ask the OneTouch library to carry out a request.
/// Will app-switch to the PayPal mobile Wallet app if present, or to web browser otherwise.
///
/// @param adapterBlock Block that makes the URL request.
/// @param completionBlock Block that is called when the request has finished initiating
///        (i.e., app-switch has occurred or an error was encountered).
///
/// @note The adapter block is responsible to determine app-switch (to Wallet, browser, or neither). After the request completionBlock is called immediately.
///       We use a completion block here to allow for future changes in implementation that might cause
///       delays (such as time-consuming cryptographic operations, or server interactions).
- (void)performWithAdapterBlock:(PayPalOneTouchRequestAdapterBlock)adapterBlock;

/// Get token from approval URL
+ (NSString *)tokenFromApprovalURL:(NSURL *)approvalURL;

/// All requests MUST include the app's Client ID, as obtained from developer.paypal.com
@property (nonatomic, readonly) NSString *clientID;

/// All requests MUST indicate the environment -
/// PayPalEnvironmentProduction, PayPalEnvironmentMock, or PayPalEnvironmentSandbox;
/// or else a stage indicated as `base-url:port`
@property (nonatomic, readonly) NSString *environment;

/// All requests MUST indicate the URL scheme to be used for returning to this app, following an app-switch
@property (nonatomic, readonly) NSString *callbackURLScheme;

/// Requests MAY include additional key/value pairs that OTC will add to the payload
/// (For example, the Braintree client_token, which is required by the
///  temporary Braintree Future Payments consent webpage.)
@property (nonatomic, strong) NSDictionary *additionalPayloadAttributes;


@end


/// Request consent for Profile Sharing (e.g., for Future Payments)
@interface PayPalOneTouchAuthorizationRequest : PayPalOneTouchRequest

/// Factory method. Non-empty values for all parameters MUST be provided.
///
/// @param scopeValues Set of requested scope-values.
///        Available scope-values are listed at https://developer.paypal.com/webapps/developer/docs/integration/direct/identity/attributes/
/// @param privacyURL The URL of the merchant's privacy policy
/// @param agreementURL The URL of the merchant's user agreement
/// @param clientID The app's Client ID, as obtained from developer.paypal.com
/// @param environment PayPalEnvironmentProduction, PayPalEnvironmentMock, or PayPalEnvironmentSandbox;
///        or else a stage indicated as `base-url:port`
/// @param callbackURLScheme The URL scheme to be used for returning to this app, following an app-switch
+ (instancetype)requestWithScopeValues:(NSSet *)scopeValues
                            privacyURL:(NSURL *)privacyURL
                          agreementURL:(NSURL *)agreementURL
                              clientID:(NSString *)clientID
                           environment:(NSString *)environment
                     callbackURLScheme:(NSString *)callbackURLScheme;

/// Set of requested scope-values.
/// Available scope-values are listed at https://developer.paypal.com/webapps/developer/docs/integration/direct/identity/attributes/
@property (nonatomic, readonly) NSSet *scopeValues;

/// The URL of the merchant's privacy policy
@property (nonatomic, readonly) NSURL *privacyURL;

/// The URL of the merchant's user agreement
@property (nonatomic, readonly) NSURL *agreementURL;

@end


/// Request approval of a payment
@interface PayPalOneTouchCheckoutRequest : PayPalOneTouchRequest

@property (nonatomic, strong) NSString *pairingId;

/// Factory method. Non-empty values for all parameters MUST be provided.
///
/// @param approvalURL Client has already created a payment on PayPal server; this is the resulting HATEOS ApprovalURL
/// @param clientID The app's Client ID, as obtained from developer.paypal.com
/// @param environment PayPalEnvironmentProduction, PayPalEnvironmentMock, or PayPalEnvironmentSandbox;
///        or else a stage indicated as `base-url:port`
/// @param callbackURLScheme The URL scheme to be used for returning to this app, following an app-switch
+ (instancetype)requestWithApprovalURL:(NSURL *)approvalURL
                              clientID:(NSString *)clientID
                           environment:(NSString *)environment
                     callbackURLScheme:(NSString *)callbackURLScheme;

/// Factory method. Only pairingId can be nil.
///
/// @param approvalURL Client has already created a payment on PayPal server; this is the resulting HATEOS ApprovalURL
/// @param pairingId The pairingId for the risk component
/// @param clientID The app's Client ID, as obtained from developer.paypal.com
/// @param environment PayPalEnvironmentProduction, PayPalEnvironmentMock, or PayPalEnvironmentSandbox;
///        or else a stage indicated as `base-url:port`
/// @param callbackURLScheme The URL scheme to be used for returning to this app, following an app-switch
+ (instancetype)requestWithApprovalURL:(NSURL *)approvalURL
                             pairingId:(NSString *)pairingId
                              clientID:(NSString *)clientID
                           environment:(NSString *)environment
                     callbackURLScheme:(NSString *)callbackURLScheme;

/// Client has already created a payment on PayPal server; this is the resulting HATEOS ApprovalURL
@property (nonatomic, readonly) NSURL *approvalURL;

@end

/// Request approval of a Billing Agreement
@interface PayPalOneTouchBillingAgreementRequest : PayPalOneTouchCheckoutRequest

@end

