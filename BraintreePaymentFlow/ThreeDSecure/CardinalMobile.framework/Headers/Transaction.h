//
//  Transaction.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationRequestParameters.h"
#import "ProgressDialog.h"
#import "ChallengeStatusReceiver.h"
#import "ChallengeParameters.h"
#import <UIKit/UIKit.h>

/**
 * An object that confronts to Transaction protocol hold parameters that the 3DS Server requires to create AReq messages and to perform the Challenge Flow.
 */
@protocol Transaction <NSObject>

/**
 * Returns device and 3DS SDK information to the 3DS Requestor App.
 * @return AuthenticationRequestParameters
 */
- (nonnull AuthenticationRequestParameters*) getAuthenticationRequestParameters;

/**
 * Initiates the challenge process.
 * @param challengeParameters ACS details (contained in the ARes) required by the 3DS SDK to conduct the challenge process during the transaction
 * @param challengeStatusReceiver Callback object for notifying the 3DS Requestor App about the challenge status.
 * @param timeOut Timeout interval (in minutes) within which the challenge process must be completed. The minimum timeout interval should be 5 minutes.
 * @param error Reference to NSError for exception handling
 */
- (BOOL) doChallengeWithChallengeParameters: (ChallengeParameters *_Nonnull) challengeParameters
                    challengeStatusReceiver: (id<ChallengeStatusReceiver>_Nonnull) challengeStatusReceiver
                                    timeOut: (int) timeOut
                                      error: (NSError *_Nullable*_Nullable)error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(doChallenge(_:challengeStatusReceiver:timeOut:));

/**
 * Returns an instance of Progress View (processing screen) that the 3DS Requestor App uses.
 * @return ProgressDialog
 */
- (ProgressDialog *_Nonnull) getProgressView;

/**
 * Cleans up resources that are held by the Transaction object.
 */
- (void) close;

@end
