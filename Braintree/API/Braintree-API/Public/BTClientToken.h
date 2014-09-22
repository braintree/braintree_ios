#import <Foundation/Foundation.h>

#import "BTErrors.h"

extern NSString *const BTClientTokenKeyAuthorizationFingerprint;
extern NSString *const BTClientTokenKeyClientApiURL;
extern NSString *const BTClientTokenKeyChallenges;
extern NSString *const BTClientTokenKeyAnalytics;
extern NSString *const BTClientTokenKeyURL;
extern NSString *const BTClientTokenKeyMerchantId;
extern NSString *const BTClientTokenKeyVersion;
extern NSString *const BTClientTokenKeyApplePay;
extern NSString *const BTClientTokenKeyStatus;

@interface BTClientToken : NSObject <NSCoding, NSCopying>

#pragma mark Braintree Client API

@property (nonatomic, readonly, copy) NSString *authorizationFingerprint;

@property (nonatomic, readonly, strong) NSURL *clientApiURL;
@property (nonatomic, readonly, strong) NSURL *analyticsURL;
@property (nonatomic, readonly, strong) NSURL *configURL;
@property (nonatomic, readonly, copy) NSString *merchantId;

-(BOOL)analyticsEnabled;

#pragma mark Configuration

- (void)updateConfiguration:(NSDictionary *)configuration;

#pragma mark Credit Card Processing

@property (nonatomic, readonly, strong) NSSet *challenges;

#pragma mark Apple Pay

@property (nonatomic, readonly, strong) NSDictionary *applePayConfiguration;

#pragma mark -

- (instancetype)initWithClientTokenString:(NSString *)JSONString error:(NSError **)error NS_DESIGNATED_INITIALIZER;

//// Initialize a client token with a dictionary of claims parsed from the client token string.
//- (instancetype)initWithClaims:(NSDictionary *)claims
//                         error:(NSError * __autoreleasing *)error;

@end
