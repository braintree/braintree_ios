//
//  Transaction.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompletionEvent.h"
#import "RuntimeErrorEvent.h"
#import "ProtocolErrorEvent.h"

/**
 * A callback object that confrotnts to ChallengeStatusReceiver protocol
 * receives challenge status notification from the 3DS SDK at the end of the challenge process.
 * This receiver object may be notified by calling various methods.
 */
@protocol ChallengeStatusReceiver


/**
 * Called when the challenge process (that is, the transaction) is completed.
 * When a transaction is completed, a transaction status shall be available.
 * @param completionEvent Information about completion of the challenge process.
 */
- (void) completed: (CompletionEvent *) completionEvent;


/**
 * Called when the Cardholder selects the option to cancel the transaction on the challenge screen.
 */
- (void) cancelled;

/**
 * Called when the challenge process reaches or exceeds the timeout interval that is specified during the doChallenge call on the 3DS SDK.
 */
- (void) timedout;

/**
 * Called when the 3DS SDK receives an EMV 3-D Secure protocol-defined error message from the ACS.
 * @param protocolErrorEvent Error code and details.
 */
- (void) protocolError: (ProtocolErrorEvent *) protocolErrorEvent;

/**
 * Called when the 3DS SDK encounters errors during the challenge process
 * These errors include all errors except those covered by the protocolError method.
 * @param runtimeErrorEvent Error code and details.
 */
- (void) runtimeError: (RuntimeErrorEvent *) runtimeErrorEvent;

@end
