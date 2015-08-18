//
// BTCoinbaseOAuth.h
//
// Vendored from the official Coinbase iOS SDK version 3.0:
// https://github.com/coinbase/coinbase-ios-sdk
//

#import <UIKit/UIKit.h>
#import "BTCoinbaseDefines.h"

///  Indicates where user authentication takes place
typedef NS_ENUM(NSInteger, BTCoinbaseOAuthAuthenticationMechanism){
    ///  Neither app switch nor authentication occured
    BTCoinbaseOAuthMechanismNone = NO,
    ///  The user authenticated with Coinbase in Mobile Safari
    BTCoinbaseOAuthMechanismBrowser,
    /// The user authenticated with Coinbase in the Coinbase app
    BTCoinbaseOAuthMechanismApp,
};

///  The key in an NSError userInfo dictionary where the coinbase specific error code is returned.
///
///  For example, when the return URL contains error=acccess_denied, the error you receive in
///  finishOAuthAuthenticationForUrl:clientId:clientSecret:completion: will contain @"access_denied"
///  in the userInfo dictionary.
extern NSString *const BTCoinbaseOAuthErrorUserInfoKey;

/// `CoinbaseOAuth` contains methods to authenticate users through OAuth2. After obtaining an
/// access token using this class, you can call Coinbase API methods
/// using `[Coinbase coinbaseWithOAuthAccessToken:]`.
@interface BTCoinbaseOAuth : NSObject

/// Test if the Coinbase app is installed and if the OAuth authentication process will use the Coinbase
/// app to offer an easier authentication process. Can be used to make the Coinbase OAuth sign in action
/// more prominent if the app is installed (thus indicating the user has an interest in Coinbase).
///
/// @returns True if the app switch was successful
+ (BOOL)isAppOAuthAuthenticationAvailable;

/// Start the OAuth authentication process. This will open a different application to complete the
/// authentication flow.
///
/// @return the mechanism of authentication. Example: CoinbaseOAuthMechanismApp
+ (BTCoinbaseOAuthAuthenticationMechanism)startOAuthAuthenticationWithClientId:(NSString *)clientId
                                                                       scope:(NSString *)scope
                                                                 redirectUri:(NSString *)redirectUri
                                                                        meta:(NSDictionary *)meta;

/// Finish the OAuth authentication process. This should be called when your application is opened
/// for a Coinbase OAuth URI.
///
/// If you pass your client secret to `clientSecret`, the OAuth access grant will be exchanged for tokens
/// on the device and returned to your in the `success` callback. If you pass nil to `clientSecret`, the
/// OAuth authorization code will be returned to your `success` callback, so you can send it to your server and
/// exchange it for tokens there. If your application has a server side component, the second approach is recommended,
/// as it prevents disclosure of the client secret to the client side.
+ (void)finishOAuthAuthenticationForUrl:(NSURL *)url
                               clientId:(NSString *)clientId
                           clientSecret:(NSString *)clientSecret
                             completion:(BTCoinbaseCompletionBlock)completion;

/// Get new tokens using a refresh token.
+ (void)getOAuthTokensForRefreshToken:(NSString *)refreshToken
                             clientId:(NSString *)clientId
                         clientSecret:(NSString *)clientSecret
                           completion:(BTCoinbaseCompletionBlock)completion;

/// Get new tokens using an authorization code.
+ (void)getOAuthTokensForCode:(NSString *)code
                  redirectUri:(NSString *)redirectUri
                     clientId:(NSString *)clientId
                 clientSecret:(NSString *)clientSecret
                   completion:(BTCoinbaseCompletionBlock)completion;

/// Make a request to a Coinbase OAuth API.
+ (void)doOAuthPostToPath:(NSString *)path
               withParams:(NSDictionary *)params
               completion:(BTCoinbaseCompletionBlock)completion;

/// Set the base URL that will be used when making API requests. Defaults to "https://api.coinbase.com/"
+ (void)setBaseURL:(NSURL *)URL;

@end
