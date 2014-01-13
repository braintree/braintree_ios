/*
 * Venmo SDK - Version 2.2.7
 *
 ******************************
 ******************************
 * VTClient.h
 ******************************
 ******************************
 *
 * The VTClient manages all view creation and delegate methods so that your users can more
 * quickly and securely make payments. If a payment method was previously entered in another
 * app on the Braintree network, you can prompt the user to use that card without her having
 * to retype the payment method credentials (i.e. credit card number).
 *
 * Please create a single instance of a VTClient within your app to manage all payment method
 * interactions. Once a client has been created using one of the custom "initWithMechantID..."
 * methods (shown below), you may use "[VTClient sharedVTClient]" to return a singleton of the
 * client object.
 *
 * The Braintree sandbox gateway environment allows for testing without using real payment details.
 * To test Venmo Touch in your sandbox environment, init your VTClient and pass in
 * VTEnvironmentSandbox as your testing environment.
 *
 * To init a VTClient, you will have to pass in your Braintree credentials: your merchantID,
 * verified customer email (if available), and client-side encryption key.
 *  1. Sandbox credentials can be found here: https://sandbox.braintreegateway.com/login
 *  2. Production credentials are found here: https://www.braintreegateway.com/login
 *
 * Setting the verified customer email address can improve the chances that the user has a
 * card available on Venmo Touch. If the verified customer email address is not available
 * at VTClient's initialization, use "setCustomerEmail" once it becomes available.
 *
 * While testing in the sandbox environment, please use your sandbox
 * credentials. Similarly, create your VTClient and pass in VTEnvironmentSandbox as your
 * testing environment.
 *
 * When you're ready to move to production, ensure that your VTClient is being initialized
 * with your production merchant account credentials and VTEnvironmentProduction.
 *
 * When users manually enter a new payment method, please create and add a VTCheckboxView
 * near the form.
 *
 * If there is at least 1 payment method on file for that user, you will be able to create a
 * VTCardView and display that to the user. The VTCardView will present the user with a
 * payment method that was entered in a previous app on this phone. The user will then have the
 * option to select that payment method for use in your app or continue with the default
 * flow to add a new payment method. We recommend adding the VTCardView directly above the
 * manual credit card entry form for optimal conversion.
 *
 * The Venmo SDK does not support iOS versions below 5.0. For iOS devices running iOS below 5.0,
 * initializing a VTClient object will return nil. Similarly, initializing touch views on devices
 * below iOS 5.0 will return nil.
 *
 ******************************
 * Adding a card to Braintree
 ******************************
 *
 * After a user manually enters card information to your app, it is the app's job to encrypt the
 * card (described below) information and send it to the merchant's servers. Then, the merchant
 * server will send the encrypted card information to Braintree for a payment token. There is
 * one additional parameter that is required to send to the Braintree servers, the parameter is
 * called "venmo_sdk_session". It is the app's job to get the "venmo_sdk_session" parameter and
 * send it to the the merchant servers alongside the encrypted credit card data.
 *
 * The app can get the "venmo_sdk_session" string in two different ways:
 *
 * 1. "[client venmoSDKSession]" returns an encrypted string. It is your job to encrypt the
 *    card data using the BraintreeEncryption library and then include the "venmo_sdk_session" as
 *    an additional parameter.
 *
 * 2. "[client encryptedCardDataAndVenmoSDKSessionWithCardDictionary:cardInformationDictionary]"
 *    will accept a read-only NSDictionary of your unencrypted card values and encrypt them using
 *    your Braintree key. Then, it will add the "venmo_sdk_session" data as an additional item
 *    in the parameters. Finally, it will return a new NSDictionary with the encrypted card
 *    data and the additional "venmo_sdk_session" parameter.
 *
 */

#import <Foundation/Foundation.h>
#import "VTCheckboxView.h"
#import "VTCardView.h"
#import "VTPaymentMethodCode.h"

// Specifies if the user has a payment method on file. If a request is still loading, the
// client's paymentMethodOptionStatus will be PaymentMethodOptionStatusLoading. If the client's
// paymentMethodOptionStatus is PaymentMethodOptionStatusYes, you should create and display
// a VTCardView. If the request for payment methods failed, you can call `refresh`.
typedef NS_ENUM(NSInteger, VTPaymentMethodOptionStatus) {
    VTPaymentMethodOptionStatusLoading,
    VTPaymentMethodOptionStatusFailed,
    VTPaymentMethodOptionStatusNo,
    VTPaymentMethodOptionStatusYes,
};

// When initializing the VTClient, you can set the environment to production or sandbox for testing.
// Sandbox testing is used in conjunction with the open-sourced VenmoSDKTestApp.
typedef NS_ENUM(NSInteger, VTEnvironment) {
    VTEnvironmentProduction,
    VTEnvironmentSandbox,
    VTEnvironmentQA,
    VTEnvironmentDevelopment
};


// Before your app is enabled with Venmo Touch, you should check the VTLiveStatus status.
// If this returns VTLiveStatusNo, you should not show any touch views. If VTLiveStatus is equal to
// VTLiveStatusLoading, the request to download that status is nil.
typedef NS_ENUM(NSInteger, VTLiveStatus) {
    VTLiveStatusNo,
    VTLiveStatusYes,
    VTLiveStatusLoading,
};

@protocol VTClientDelegate;

@interface VTClient : NSObject

@property (nonatomic, copy, readonly) NSString *merchantID;
@property (nonatomic, copy, readonly) NSString *braintreeClientSideEncryptionKey;
@property (nonatomic, copy, readonly) NSString *versionNumber;
@property (nonatomic, copy) NSString *customerEmail;
@property (nonatomic, weak) id<VTClientDelegate>delegate;


// A convenience method that begins your VTClient work. To refer to the underlying vtClient object,
// use [VTClient sharedVTClient] below.
+ (void)startWithMerchantID:(NSString *)merchantID customerEmail:(NSString *)customerEmail braintreeClientSideEncryptionKey:(NSString *)braintreeCSEKey;
+ (void)startWithMerchantID:(NSString *)merchantID customerEmail:(NSString *)customerEmail braintreeClientSideEncryptionKey:(NSString *)braintreeCSEKey environment:(VTEnvironment)VTEnvironment;

// A convenience method that returns a singleton of the VTClient that was created by one of
// the custom "initWithMechantID..." functions below.
+ (VTClient *)sharedVTClient;

// Inits a VTClient object.
// Default Venmo SDK environment is VTEnvironmentProduction. To test Venmo Touch in your Braintree
// sandbox environment, use "initWithMerchantID:braintreeClientSideEncryptionKey:environment:" below.
//
// Your production merchantID and braintreeCSEKey are here: https://www.braintreegateway.com/login
- (id)initWithMerchantID:(NSString *)merchantID customerEmail:(NSString *)customerEmail braintreeClientSideEncryptionKey:(NSString *)braintreeCSEKey;

// Inits a VTClient object where you can specify the VTEnvironment. Setting the environment
// to VTEnvironmentSandbox will allow you to test in your Braintree gateway sandbox
// testing environment.
//
// Your production merchantID and braintreeCSEKey are here: https://www.braintreegateway.com/login
// Sandbox merchantID and braintreeCSEKey are here: https://sandbox.braintreegateway.com/login
- (id)initWithMerchantID:(NSString *)merchantID customerEmail:(NSString *)customerEmail braintreeClientSideEncryptionKey:(NSString *)braintreeCSEKey environment:(VTEnvironment)VTEnvironment;

// Returns the status of a user's payment methods as defined by PaymentMethodOptionStatus.
- (VTPaymentMethodOptionStatus)paymentMethodOptionStatus;

// Creates a VTCheckboxView view, do NOT use [[VTCheckboxView alloc] init].
- (VTCheckboxView *)checkboxView;

// You must use this method to create a VTCardView, do NOT use [[VTCardView alloc] init].
// If your VTClient's paymentMethodOptionStatus is PaymentMethodOptionStatusLoading
// PaymentMethodOptionStatusFailed, or PaymentMethodOptionStatusNo, this method will return nil.
// Default behavior is to not show a picture (can be changed dynamically).
- (VTCardView *)cardView;

// Returns encryptedCardForm based on a dictionary of the raw card input information.
// You must send it to your servers and exchange it with Braintree for a payment_token.
- (NSDictionary *)encryptedCardDataAndVenmoSDKSessionWithCardDictionary:(NSDictionary *)cardDictionary;

// Returns an encrypted string using your braintreeClientSideEncryptionKey. You must include this string
// as an additional parameter with the key "venmo_sdk_session" when submiting a card to the
// Braintree vault from your server.
- (NSString *)venmoSDKSession;

// Returns if the Venmo SDK is live. While the network request is still running, this will
// return VTLiveStatusLoading. If this returns VTLiveStatusNo or VTLiveStatusLoading,
// VTCardView and VTCheckboxView cannot be created successfully.
- (VTLiveStatus)liveStatus;

// Refreshes the Venmo SDK by deleting any payment methods on file and re-downloading payment
// methods for that user. This will be useful, for example, if the the device has no service
// and did not successfully download cards previously
// (will be denoted by [client liveStatus] == VTLiveStatusLoading).
//
// If your app is displaying any VTCardViews, they should be removed from the screen and
// references to it should be set to nil. You do not have to edit or delete existing
// VTCheckboxView's from the app.
- (void)refresh;

// Restarts the session for this device. If the user had any payment methods on file, those
// payment methods will no longer be on file.
//
// NOTE: This method will only work for testing on sandbox (VTEnvironmentSandbox)
// e.g. if your VTClient was init'd with VTEnvironment as VTEnvironmentSandbox.
- (void)restartSession;

@end

//__________________________________________________________________________________________________
// this protocol notifies the parent app about user state and actions performed by user on Venmo Touch views

@protocol VTClientDelegate <NSObject>

@optional
// This method fires when the client receives a call to "refresh". VTClient performs a network
// call to check if payment methods (e.g. cards) are on file for this user.
// When a VTClient is first initialized, this function will also be called. This method may
// be useful in order to update your UI to prepare for client:didReceivePaymentMethodOptionStatus:.
- (void)clientWillReceivePaymentMethodOptionStatus:(VTClient *)client;

// This method is triggered when the check for cards finishes loading. Once it returns, the client's
// paymentMethodOptionStatus will be set to PaymentMethodOptionStatusNo or
// PaymentMethodOptionStatusYes. You may want to implement this method if you're credit card
// input form is visible and the client has not finished its call to check for cards. Once this
// method fires, you can check the paymentMethodOptionStatus and render the a VTCardView
// if possible.
- (void)client:(VTClient *)client didReceivePaymentMethodOptionStatus:(VTPaymentMethodOptionStatus)paymentMethodOptionStatus;

// A network request is sent out to determine if the Venmo Touch is live. When it returns, this
// delegate method will trigger, returning a VTLiveStatus flag. If your app isn't showing
// the VTCheckboxView unless Venmo Touch is live, this is a good place to do so.
- (void)client:(VTClient *)client didFinishLoadingLiveStatus:(VTLiveStatus)liveStatus;

// After a user gives permission to use this card and answers any security questions, this delegate
// method will fire. The paymentMethodCode return value can be used to make payments
// through the Braintree gateway.
- (void)client:(VTClient *)client approvedPaymentMethodWithCode:(NSString *)paymentMethodCode;

// Similar to approvedPaymentMethodWithCode, this returns an object that contains additional information about the
// card referenced by the payment method code.
- (void)client:(VTClient *)client approvedPaymentMethodWithCodeAndCard:(VTPaymentMethodCode *)paymentMethodCode;

// If a user logs out, all sessions are deleted and you should remove any VTCardViews.
- (void)clientDidLogout:(VTClient *)client;

@end
