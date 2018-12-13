//
//  CardinalStepUpResponse.h
//  CardinalMobile
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @interface CardinalStepUpResponse Step Up Response
 * @brief A response object from the user to the challenge flow.
 * Includes response data or cetain requests like cancel, resend, etc from the user.
 */
@interface CardinalStepUpResponse : NSObject

/*!
 * @property challengeCancel Challenge Cancel Indicator
 * @brief Indicator that lets the ACS and DS that authentication has been canceled
 * Possible Values:
 * 1 - Cardholder chose other payment
 * 2 - Cardholder selected cancel and continue shopping
 * 3 - Merchant canceled
 * 4 - Transaction timeout at ACS
 * 6 - Transaction Error
 * 7 - Unknown
 *
 * Default Value: @""
 */
@property (nonatomic) NSString *challengeCancel;

/*!
 * @property challengeDataEntry Challenge Data Entry
 * @brief Contains data the cardholder entered into the Native UI text field.
 * Default Value: @""
 */
@property (nonatomic) NSString *challengeDataEntry;

/*!
 * @property challengeHTMLDataEntry Challenge HTML Data Entry
 * @brief Contains data the cardholder entered into the the HTML UI.
 * Default Value: @""
 */
@property (nonatomic) NSString *challengeHTMLDataEntry;

/*!
 * @property oobContinue OOB Continue
 * @brief Indicator notifying the ACS that Cardholder has completed the authentication as requested by selecting the Continue button in an Out-of-Band (OOB) authentication method.
 * Default Value: NO
 */
@property (nonatomic) BOOL oobContinue;

/*!
 * @property resendChallenge Resend Challenge
 * @brief Indicator to the ACS to resend the challenge information code to the Cardholder.
 * Default Value: @"N"
 */
@property (nonatomic) NSString *resendChallenge;

@end
