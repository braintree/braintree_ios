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

