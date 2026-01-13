//
//  CardinalServiceProtocol.h
//  CardinalMobile
//  Copyright © 2022 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardinalSessionConfiguration.h"
#import "ChallengeParameters.h"
#import "CardinalResponse.h"
#import "Warning.h"
#import "CardBrandConfig.h"
#import "CardinalError.h"
#import "ChallengeStatusReceiver.h"
#import "CardinalSessionConfigPrivate.h"
#import "GMEllipticCurveCrypto.h"
#import "CertificateInfoConfiguration.h"
#import "CardinalChallengeParameters.h"
#import "CardBrandConfig.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^CardinalServiceOnSuccess)(NSString* sdkTransactionID);
typedef void (^CardinalServiceOnError)(CardinalError* _Nullable error);
@protocol CardinalServiceProtocol <NSObject>

@property (nonatomic, strong, nullable) NSString *merchantJWT;
@property (nonatomic, strong, nullable) CardinalSessionConfiguration *cardinalConfig;
@property (nullable, nonatomic, strong) NSTimer *timeoutTimer;
@property (nullable, nonatomic,strong) NSArray<Warning *>* warnings;
/*!
    @brief It initializes cardinal mobile SDK with merchant JWT.
 
    @discussion This method accepts a String value representing the merchantJWT, a CardinalSessionConfigurationObject representing CardinalSessionConfiguration. This is a void method with call backs CardinalServiceOnComplete which return a String value representing SDKTransactionID and a callback CardinalServiceOnError which return a CMError Object with the error details

               To use it, simply call @c[[[CardinalService alloc] init] initializeWithJWT:@"" configParameters:CardinalSessionConfiguration.new onSuccess:^(NSString * _Nonnull sdkTransactionID) {
                                
                               }  onError:^(CardinalError * error) {
  }];

    @param  merchantJWT The input value representing the merchant JWT.
    @param  configParameters The input value representing the CardinalSessionConfiguration
    @param  successCompletionHandler The input value representing the CardinalServiceOnSuccess callback
    @param  errorCompletionHandler The input object error representing CardinalServiceOnError callback which gives back CMError object(error code and description)
 */
@required
- (void)initializeWithJWT:(NSString *)merchantJWT
         configParameters:(CardinalSessionConfiguration *)configParameters
                onSuccess:(CardinalServiceOnSuccess)successCompletionHandler
                  onError:(CardinalServiceOnError)errorCompletionHandler NS_SWIFT_NAME(jwtInitialize(jwtString:configParameters:success:error:));

/**
 *  Returns Cardinal Encrypted Data.
 *  @param cardBrand cardBrand from the certificates merchants send.
 *  @param error Reference to CardinalError for exception handling
 */
- (NSString *)getAuthenticationForCardBrand:(NSString *)cardBrand error:(CardinalError * _Nullable __autoreleasing *_Nullable)error NS_SWIFT_NAME(getAuthenticationForCardBrand(cardBrand:error:));

/**
 *  Returns Cardinal Encrypted Data.
 *  @param cardBrand cardBrand from the certificates merchants send.
 *  @param messageVersion EMVCO Protocol version according to which the transaction shall be created.
 *  @param error Reference to CardinalError for exception handling
 */
- (NSString *)getAuthentication:(NSString *)cardBrand
              withMessageVersion:(NSString *)messageVersion
                          error:(CardinalError * _Nullable __autoreleasing *_Nullable)error NS_SWIFT_NAME(getAuthentication(cardBrand:messageVersion:error:));
/**
 * Initiates the challenge process.
 * @param challengeParameters challengeParameters from Merchants which includes details about the transaction.
 * @param timeOut timeOut
 * @param challengeStatusReceiver Callback object for notifying the 3DS Requestor App about the challenge status.
 * @param error Reference to NSError for exception handling
 */
- (void) doChallengewithChallengeParameters: (CardinalChallengeParameters *)challengeParameters
                    challengeStatusReceiver: (id<ChallengeStatusReceiver>_Nonnull) challengeStatusReceiver
                                    timeOut:(int)timeOut
                                      error: (CardinalError * _Nullable __autoreleasing *_Nullable)error  NS_SWIFT_NAME(doChallengewithChallengeParameters(challengeParameters:challengeStatusReceiver:timeOut:error:));

/**
 * The getWarnings method returns the warnings produced by the 3DS SDK during initialization.
 * @return List of Warnings
 */
- (NSArray<Warning *> *) getWarnings;

/**
 * The cleanup method frees up resources that are used by the SDK.
 */
- (void)cleanup;
@end

NS_ASSUME_NONNULL_END

