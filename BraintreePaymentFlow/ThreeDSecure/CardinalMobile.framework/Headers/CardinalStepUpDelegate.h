//
//  CardinalReceiver.h
//  CardinalMobile
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CardinalStepUpData;
@class CardinalResponse;
@class CardinalSession;

/*!
 * @protocol CardinalValidationDelegate Validation Delegate
 * @brief Delegate for various responses from the Cardinal Step Up flow after cardinalSession continue method being called.
 */
@protocol CardinalValidationDelegate

/*!
 * This method is triggered when the transaction has been terminated.This is how SDK hands back
 * control to the merchant's application. This method will
 * include data on how the transaction attempt ended and
 * you should have your logic for reviewing the results of
 * the transaction and making decisions regarding next steps.
 * JWT will be empty if validate was not successful
 *
 * @param session CardinalSession that is validated for.
 * @param validateResponse Response to the StepUpData Validation.
 * @param serverJWT JWT of the trasaction. Nil if validation is unsuccessful.
 */
- (void)cardinalSession:(CardinalSession *)session
stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse
              serverJWT:(NSString *)serverJWT NS_SWIFT_NAME(cardinalSession(cardinalSession:stepUpValidated:serverJWT:));
@end

/*!
 * @protocol CardinalStepUpDelegate Step Up Delegate
 * @brief Delegate for various responses from the Cardinal Step Up flow after cardinalSession continue method being called.
 */
@protocol CardinalStepUpDelegate<CardinalValidationDelegate>


/*!
 * This method is called when the Step up data is ready for use.
 * Determine which UI to display and
 * display using the details provided in the stepUpData object
 *
 * @param session CardinalSession whose StepUpData did become ready.
 * @param stepUpData CardinalStepUpData that provides the detail of StepUp Challenge.
 */
- (void)cardinalSession:(CardinalSession *)session
stepUpDataDidBecomeReady:(CardinalStepUpData *)stepUpData NS_SWIFT_NAME(cardinalSession(cardinalSession:stepUpDataReady:));

/*!
 * This method is typically called when user request for resending
 * an OTP. Merchant application has to repaint the
 * same current context with updated fields
 *
 * @param session CardinalSession whose StepUpData did update.
 * @param stepUpData CardinalStepUpData that provides the updated StepUp Challenge.
 */
- (void)cardinalSession:(CardinalSession *)session
    stepUpDataDidUpdate:(CardinalStepUpData *)stepUpData NS_SWIFT_NAME(cardinalSession(cardinalSession:stepUpDataUpdated:));

@end
