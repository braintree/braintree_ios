/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VInitInfo.h"

extern NSString * _Nonnull const kVisaCountryCodeArgentina;
extern NSString * _Nonnull const kVisaCountryCodeAustralia;
extern NSString * _Nonnull const kVisaCountryCodeBrazil;
extern NSString * _Nonnull const kVisaCountryCodeCanada;
extern NSString * _Nonnull const kVisaCountryCodeChile;
extern NSString * _Nonnull const kVisaCountryCodeChina;
extern NSString * _Nonnull const kVisaCountryCodeColombia;
extern NSString * _Nonnull const kVisaCountryCodeFrance;
extern NSString * _Nonnull const kVisaCountryCodeHongKong;
extern NSString * _Nonnull const kVisaCountryCodeIndia;
extern NSString * _Nonnull const kVisaCountryCodeIreland;
extern NSString * _Nonnull const kVisaCountryCodeMalaysia;
extern NSString * _Nonnull const kVisaCountryCodeMexico;
extern NSString * _Nonnull const kVisaCountryCodeNewZealand;
extern NSString * _Nonnull const kVisaCountryCodePeru;
extern NSString * _Nonnull const kVisaCountryCodePoland;
extern NSString * _Nonnull const kVisaCountryCodeSingapore;
extern NSString * _Nonnull const kVisaCountryCodeSouthAfrica;
extern NSString * _Nonnull const kVisaCountryCodeSpain;
extern NSString * _Nonnull const kVisaCountryCodeUnitedArabEmirates;
extern NSString * _Nonnull const kVisaCountryCodeUnitedKingdom;
extern NSString * _Nonnull const kVisaCountryCodeUnitedStates;
extern NSString * _Nonnull const kVisaCountryCodeUkraine;
extern NSString * _Nonnull const kVisaCountryCodeKuwait;
extern NSString * _Nonnull const kVisaCountryCodeSaudiArabia;
extern NSString * _Nonnull const kVisaCountryCodeQatar;

extern NSString * _Nonnull const kVisaCardBrandVisa;
extern NSString * _Nonnull const kVisaCardBrandElo;
extern NSString * _Nonnull const kVisaCardBrandAmex;
extern NSString * _Nonnull const kVisaCardBrandDiscover;
extern NSString * _Nonnull const kVisaCardBrandElectron;
extern NSString * _Nonnull const kVisaCardBrandMastercard;

extern NSString * _Nonnull const kAcceptCanadianDebitCards;
extern NSString * _Nonnull const kAcceptedBillingCountries;
extern NSString * _Nonnull const kAcceptedCardBrands;
extern NSString * _Nonnull const kAcceptedShippingCountries;
extern NSString * _Nonnull const kApiKey;
extern NSString * _Nonnull const kClientId;
extern NSString * _Nonnull const kExternalClientId;
extern NSString * _Nonnull const kDatalevel;
extern NSString * _Nonnull const kDisplayName;
extern NSString * _Nonnull const kWebsiteUrl;
extern NSString * _Nonnull const kCustomerSupportUrl;
extern NSString * _Nonnull const kEnvironment;
extern NSString * _Nonnull const kEncryptionKey;
extern NSString * _Nonnull const kProfileName;
extern NSString * _Nonnull const kLocale;
extern NSString * _Nonnull const kCountryCode;
extern NSString * _Nonnull const kWelcomeMessage;
extern NSString * _Nonnull const kWelcomeMessageDescription;
extern NSString * _Nonnull const kReturningUserWelcomeMessage;
extern NSString * _Nonnull const kEnableTokenization;
extern NSString * _Nonnull const kCampaignUrl;

/**
 This type represents a country that Visa Checkout supports.
 */
typedef NS_ENUM(NSInteger, VisaCountry) {
    /// Argentina
    VisaCountryArgentina,
    /// Australia
    VisaCountryAustralia,
    /// Brazil
    VisaCountryBrazil,
    /// Canada
    VisaCountryCanada,
    /// Chile
    VisaCountryChile,
    /// China
    VisaCountryChina,
    /// Colombia
    VisaCountryColombia,
    /// France
    VisaCountryFrance,
    /// Hong Kong
    VisaCountryHongKong,
    /// India
    VisaCountryIndia,
    /// Ireland
    VisaCountryIreland,
    /// Malaysia
    VisaCountryMalaysia,
    /// Mexico
    VisaCountryMexico,
    /// New Zealand
    VisaCountryNewZealand,
    /// Peru
    VisaCountryPeru,
    /// Poland
    VisaCountryPoland,
    /// Singapore
    VisaCountrySingapore,
    /// South Africa
    VisaCountrySouthAfrica,
    /// Spain
    VisaCountrySpain,
    /// United Arab Emirates
    VisaCountryUnitedArabEmirates,
    /// United Kingdom
    VisaCountryUnitedKingdom,
    /// United States
    VisaCountryUnitedStates,
    /// Ukraine
    VisaCountryUkraine,
    /// Kuwait
    VisaCountryKuwait,
    /// Saudi Arabia
    VisaCountrySaudiArabia,
    /// Qatar
    VisaCountryQatar
} NS_SWIFT_NAME(Country);

/**
 A brand of credit card associated with a payment
 */
typedef NS_ENUM(NSInteger, VisaCardBrand) {
    /// American Express
    VisaCardBrandAmex,
    /// Discover
    VisaCardBrandDiscover,
    /// Electron
    VisaCardBrandElectron,
    /// Elo
    VisaCardBrandElo,
    /// Mastercard
    VisaCardBrandMastercard,
    /// Visa
    VisaCardBrandVisa,
    /// Invalid
    VisaCardBrandInvalid
} NS_SWIFT_NAME(CardBrand);

/**
 The level of detail Visa Checkout sends back in the `VisaCheckoutResult` object once the transaction completes.
 */
typedef NS_ENUM(NSInteger, VisaDataLevel) {
    /// Includes all of the transaction information
    VisaDataLevelFull,
    /// Only the `statusCode` and `callId` are returned.
    VisaDataLevelNone,
    /// Includes some, but not all of the transaction information.
    VisaDataLevelSummary
} NS_SWIFT_NAME(DataLevel);

/**
 Environment is the context in which Visa Checkout SDK will connect. For testing
 and debugging purposes, `VisaEnvironmentSandbox` should be used. When deploying to the general
 public, `VisaEnvironmentProduction` must be used.
 
 Each environment will have a different `apiKey` associated with it. It is important
 to remember to change the API Key to the production API Key value before submitting
 apps to the App Store.
 */
typedef NS_ENUM(NSInteger, VisaEnvironment) {
    /**
     Production is used for deploying your app to the general public for
     use. This environment will use live Visa Checkout accounts.
     
     You must remember to use a separate `apiKey` for `VisaEnvironmentProduction` than you use
     for `VisaEnvironmentSandbox`. It is important to remember to change the API Key to
     the correct one before publishing your app to the general public.
     */
    VisaEnvironmentProduction,
    
    /**
     Sandbox is used for debugging and integration testing. Anyone can create
     Visa Checkout accounts and submit test payments without any effect on
     real world credit card transactions. There is minimal validation on
     credit card details and addresses, but otherwise is a simulated production
     environment.
     
     You must remember to use a separate `apiKey` for `VisaEnvironmentSandbox` than you use
     for `VisaEnvironmentProduction`. It is important to remember to change the API Key to
     the correct one before publishing your app to the general public.
     */
    VisaEnvironmentSandbox
} NS_SWIFT_NAME(Environment);

/**
 The `VisaProfile` class is the mechanism to customize the Visa Checkout SDK's
 configuration. These settings allow various modifications to the way
 the SDK behaves and also the way it appears to your users.
 */
NS_SWIFT_NAME(Profile)
@interface VisaProfile : VInitInfo

/**
 Set false if Canadian debit cards are not accepted.
 Default is true.
 */
@property (nonatomic, assign) BOOL acceptCanadianDebitCards;

/**
 The countries you are able to accept billing information from.
 Please use any of the string constants available such as `kVisaCountryCodeAustralia` or `kVisaCountryCodeUnitedStates`, for example.
 Additionally, you can use the raw integer representation of a `VisaCountry` enum.
 */
@property (nonatomic, strong) NSArray *_Nullable acceptedBillingCountries;

/**
 The countries you are able to accept billing information from.
 Please use any of the string constants available such as `kVisaCountryCodeAustralia` or `kVisaCountryCodeUnitedStates`, for example.
 Additionally, you can use the raw integer representation of a `VisaCountry` enum.
 */
- (void)acceptedBillingCountries:(NSArray* _Nonnull)countries DEPRECATED_MSG_ATTRIBUTE("Use acceptedBillingCountries property instead.");

/**
 The card brands that are accepted as valid payment types.
 Please use any of the string constants available such as `kVisaCardBrandVisa` or `kVisaCardBrandDiscover`, for example.
 Additionally, you can use the raw integer representation of a `VisaCardBrand` enum.
 */
@property (nonatomic, strong) NSArray *_Nullable acceptedCardBrands;

/**
 The card brands that are accepted as valid payment types.
 Please use any of the string constants available such as `kVisaCardBrandVisa` or `kVisaCardBrandDiscover`, for example.
 Additionally, you can use the raw integer representation of a `VisaCardBrand` enum.
 */
- (void)acceptedCardBrands:(NSArray<NSNumber *> * _Nonnull)brands DEPRECATED_MSG_ATTRIBUTE("Use acceptedCardBrands property instead.");

/**
 The countries you are able to ship to.
 Please use any of the string constants available such as `kVisaCountryCodeAustralia` or `kVisaCountryCodeUnitedStates`, for example.
 Additionally, you can use the raw integer representation of a `VisaCountry` enum.
 */
@property (nonatomic, strong) NSArray *_Nullable acceptedShippingCountries;

/**
 The countries you are able to ship to.
 Please use any of the string constants available such as `kVisaCountryCodeAustralia` or `kVisaCountryCodeUnitedStates`, for example.
 Additionally, you can use the raw integer representation of a `VisaCountry` enum.
 */
- (void)acceptedShippingCountries:(NSArray<NSNumber *> * _Nonnull)countries DEPRECATED_MSG_ATTRIBUTE("Use acceptedShippingCountries property instead.");

/**
 The API Key string given associated with your Visa Merchant account.
 This key will be dependent on which `VisaEnvironment` you are connecting to. For instance, you
 will have one API Key for the Sandbox `VisaEnvironment` and a different API Key for the Production `VisaEnvironment`.
 */
@property (nonatomic, strong) NSString *_Nonnull apiKey;

/**
 Set the client id if needed
 */
@property (nonatomic, strong) NSString *_Nullable clientId;

/**
 Not required for merchants. For partners, it is the unique ID 
 associated with a partner's client, such as the ID of a merchant 
 onboarded by the partner. Typically, the external client ID is assigned by a partner; 
 however, Visa Checkout assigns a value if one is not specified.
 */
@property (nonatomic, strong) NSString *_Nullable externalClientId;

/**
 The level of detail that is returned on the `VisaCheckoutResult`
 object after the user completes a Visa Checkout transaction.
 */
@property (nonatomic, assign) VisaDataLevel datalevel;

/**
 How Visa Checkout should refer to your company/app
 */
@property (nonatomic, strong) NSString *_Nullable displayName;

/**
 Complete URL to your website.
 */
@property (nonatomic, strong) NSString *_Nullable websiteUrl;

/**
 Your complete customer service or support URL.
 */
@property (nonatomic, strong) NSString *_Nullable customerSupportUrl;

/**
 Set this to true to enable tokenization.
 */
@property (nonatomic, assign) BOOL enableTokenization;

/**
 The server environment to use
 */
@property (nonatomic, assign) VisaEnvironment environment;

/**
 Specify the encryption key to be used by Visa
 */
@property (nonatomic, strong) NSString *_Nullable encryptionKey;

/**
 The profile name associated with your Visa Merchant account. Default is *default*.
 */
@property (nonatomic, strong) NSString *_Nullable profileName;

/**
 The locale, which controls how text displays.
 */
@property (nonatomic, strong) NSString *_Nullable locale;

/**
 Country code of the country where the purchase should be shipped, such as US;
 useful for calculating shipping costs.
 */
@property (nonatomic, strong) NSString *_Nullable countryCode;

/**
 Welcome message for the new user.
 */
@property (nonatomic, strong) NSString *_Nullable welcomeMessage;

/**
 Welcome message description.
 */
@property (nonatomic, strong) NSString *_Nullable welcomeMessageDescription;

/**
 Welcome message for a returning user.
 */
@property (nonatomic, strong) NSString *_Nullable returningUserWelcomeMessage;

/**
 Initializer with basic information required to configure the
 Visa Checkout SDK.

 @param environment The `VisaEnvironment`.
 @param apiKey The `apiKey`.
 @param profileName The `profileName`.
 */
- (instancetype _Nonnull)initWithEnvironment:(VisaEnvironment)environment apiKey:(NSString *_Nonnull)apiKey profileName:(NSString *_Nullable)profileName;

/**
 Apply child directed treatment for Google ad tracking if COPPA compliance is necessary.
 Default value is `false`.
 */
@property (nonatomic) BOOL applyChildDirectedTreatmentForGoogleAds DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");

/**
 If you provide this along with `facebookAdvertisingID`, we will
 send Visa Checkout screen visible events to your facebook event tracker on your
 behalf
 */
@property (nonatomic, copy) NSString * _Nullable facebookAppID DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");

/**
 If you provide this along with `facebookAppID`, we will
 send Visa Checkout screen visible events to your facebook event tracker on your
 behalf. This should be the value of Apple's Advertising Identifier (IDFA).
 */
@property (nonatomic, copy) NSString * _Nullable facebookAdvertisingID DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");

/**
 Provide the file name of a custom PNG logo to be
 shown inside Visa Checkout. The file should be a
 resource accessible by your app bundle.
 */
@property (nonatomic, copy) NSString * _Nullable logo DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");

@end
