#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
An authorization token used to initialize the Braintree SDK
*/
@interface BTPayPalIDToken : NSObject

/**
 Initialize a PayPal ID Token with an ID Token string.
 */
- (nullable instancetype)initWithIDTokenString:(NSString *)payPalIDToken error:(NSError **)error NS_DESIGNATED_INITIALIZER;

/**
Base initializer - do not use.
*/
- (instancetype)init __attribute__((unavailable("Please use initWithPayPalIDToken:error: instead.")));

/**
 The extracted authorization fingerprint
 */
@property (nonatomic, readonly, copy) NSString *token;

/**
 The extracted configURL
 */
@property (nonatomic, readonly, strong) NSURL *configURL;

/**
 The base Braintree URL
 */
@property (nonatomic, readonly, strong) NSURL *baseBraintreeURL;

/**
 The base PayPal URL
 */
@property (nonatomic, readonly, strong) NSURL *basePayPalURL;

/**
 The PayPal merchant ID embedded in the token
 */
@property (nonatomic, readonly, strong) NSString *paypalMerchantID;

/**
 The Braintree merchant ID embedded in the token
 */
@property (nonatomic, readonly, strong) NSString *braintreeMerchantID;

/**
Environment codes associated with PayPal ID Token.
*/
typedef NS_ENUM(NSInteger, BTPayPalIDTokenEnvironment) {
    /// Staging
    BTPayPalIDTokenEnvironmentStage = 0,

    /// Sandbox
    BTPayPalIDTokenEnvironmentSand = 1,

    /// Production
    BTPayPalIDTokenEnvironmentProd = 2
};

/**
 The environment context of the provided PayPal ID Token
 */
@property (nonatomic, readonly, assign) BTPayPalIDTokenEnvironment environment;

/**
 Error codes associated with a PayPal ID Token.
 */
typedef NS_ENUM(NSInteger, BTPayPalIDTokenError) {
    /// Unknown error
    BTPayPalIDTokenErrorUnknown = 0,

    /// Invalid
    BTPayPalIDTokenErrorInvalid,

    /// Missing associated merchant ID
    BTPayPalIDTokenErrorUnlinkedAccount,
};

@end

NS_ASSUME_NONNULL_END
