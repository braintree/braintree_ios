//
//  CardinalSession.h
//  CardinalMobileSDK
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Warning.h"
#import "DirectoryServerIDConst.h"

NS_ASSUME_NONNULL_BEGIN

@class CardinalResponse;
@class CardinalSessionConfiguration;
@protocol CardinalValidationDelegate;


/*!
 * Code block to be invoked on the main thread upon successful completion of Cardinal Setup.
 * If an error occurs this code block will not be invoked.
 *
 * @param consumerSessionId Pass this parameter to a CMPI LookUp upon successful completion of Setup.
 */
typedef void (^CardinalSessionSetupDidCompleteHandler)(NSString *consumerSessionId);

/*!
 * Code block to be invoked on the main thread if Cardinal Setup fails.
 * If no error occurs this code block will not be invoked.
 *
 * @param validateResponse This parameter will populated with data to indicate what problem occurred during Setup.
 */
typedef void (^CardinalSessionSetupDidValidateHandler)(CardinalResponse *validateResponse);

/*!
 * Code block to be invoked on the main thread upon successful completion of the Process Bin step.
 * If an error occurs this code block will not be invoked.
 */
typedef void (^CardinalSessionProcessBinDidCompleteHandler)(void);


/*!
 * @interface CardinalSession
 * @brief CardinalSession Class for configuring, setting up and providing information for a given session of transaction.
 */
@interface CardinalSession : NSObject

/*!
 * Sets parameters for this session
 * @param sessionConfig configurations for current CardinalSession
 */
- (void)configure:(CardinalSessionConfiguration*)sessionConfig;

/*!
 * Sets up the "frictionless" transaction flow that allows your app to provide its own JWT.
 * Only one of the handler code blocks will be invoked, depending on whether Cardinal Setup was successful or not. Handlers will be invoked on the main thread.
 * @param jwtString A valid JSON Web Token string obtained from the server.
 * @param didCompleteHandler Code to be invoked upon successful completion of Cardinal Setup.
 * @param didValidateHandler Code to be invoked if a problem occurs when attempting Cardinal Setup.
 */
- (void)setupWithJWT:(NSString*)jwtString
         didComplete:(CardinalSessionSetupDidCompleteHandler)didCompleteHandler
         didValidate:(CardinalSessionSetupDidValidateHandler)didValidateHandler NS_SWIFT_NAME(setup(jwtString:completed:validated:));

#if TARGET_OS_IOS
/*!
 * Sets up the frictionless "Quick Authentication" transaction flow that allows your app to provide its own JWT and account number.
 * Only one of the handler code blocks will be invoked, depending on whether Cardinal Setup was successful or not. Handlers will be invoked on the main thread.
 * @brief This property is deprecated in v2.2.4. This feature will no longer be supported in the SDK.
 * @param jwtString A valid JSON Web Token string obtained from the Midas server.
 * @param accountNumber A valid account number ("bin number") string.
 * @param didCompleteHandler Code to be invoked upon successful completion of Cardinal Setup.
 * @param didValidateHandler Code to be invoked if a problem occurs when attempting Cardinal Setup.
 */
- (void)setupWithJWT:(NSString*)jwtString
       accountNumber:(NSString*)accountNumber
         didComplete:(CardinalSessionSetupDidCompleteHandler)didCompleteHandler
         didValidate:(CardinalSessionSetupDidValidateHandler)didValidateHandler NS_SWIFT_NAME(setup(jwtString:account:completed:validated:))__deprecated;

/*!
 * Process a "Bin" account number as part of the "Quick Authentication" transaction flow.
 * May be invoked multiple times with different account numbers.
 * @brief This property is deprecated in 2.2.4. This feature will no longer be supported in the SDK.
 * @param accountNumber A valid account number ("bin number") string.
 * @param didCompleteHandler Code to be invoked upon successfully processing an account number. Handler will be invoked on the main thread.
 */
- (void)processBin:(NSString*)accountNumber
       didComplete:(nullable CardinalSessionProcessBinDidCompleteHandler)didCompleteHandler NS_SWIFT_NAME(processBin(_:completed:))__deprecated;
#endif

/*!
 * Continue the challenge flow using SDK Controlled UI with the transaction id and encoded payload.
 * @param transactionId Transaction ID
 * @param payload Encoded Payload from Lookup
 * @param validationDelegate Class confronting to CardinalValidationDelegate protocol which receives the Validation Response after the challenge completion.
 */
- (void)continueWithTransactionId:(nonnull NSString *)transactionId
                          payload:(nonnull NSString *)payload
              didValidateDelegate:(nonnull id<CardinalValidationDelegate>)validationDelegate NS_SWIFT_NAME(continueWith(transactionId:payload:validationDelegate:));

/**
 * The getWarnings method returns the warnings produced by the 3DS SDK during initialization.
 * @return List of Warnings
 */
- (NSArray<Warning *> *)getWarnings;

/**
 * The getSDKBuildNumber method returns the build number of the Cardinal Mobile SDK.
 * @return SDK Build Number
 */
+ (NSString *)getSDKBuildNumber;

/**
* The getSDKBuildNumber method returns the build version of the Cardinal Mobile SDK.
 * @return SDK Build Version
 */
+ (NSString *)getSDKBuildVersion;

@end

NS_ASSUME_NONNULL_END
