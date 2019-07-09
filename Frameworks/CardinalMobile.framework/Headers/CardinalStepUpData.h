//
//  StepUpData.h
//  CardinalMobile
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardinalImageUrl.h"

/*!
 * @typedef CCAStepUpDataKey
 * @brief NSString to represent the StepUpData Key.
 */
typedef NSString *CCAStepUpDataKey;

/*!
 * @typedef CCAStepUpDataDictionary
 * @brief NSDictionary to represent the Dictionary of StepUpData Key to Value of any type pair.
 */
typedef NSDictionary<CCAStepUpDataKey,id> CCAStepUpDataDictionary;

/*!
 * @interface CardinalStepUpData Step Up Data
 * @brief An object containing information regarding StepUp Challenge.
*/
@interface CardinalStepUpData : NSObject

/*!
 * @property threeDSServerTransID 3DS Server Transaction ID
 * @brief Universally unique transaction identifier assigned by the 3DS Server to identify a single
 * transaction. Must be in the canonical format as defined in IETF RFC 4122. May utilise any of
 * the specified versions if the output meets specified requirements.
 * Source: 3DS Server
 * Length: 36 characters
 * Format: String
 * Value: UUID
 * Device Channel: 01-APP, 02-BRW
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion:
 * AReq = R
 * ARes = R
 * StepUpRequest = R
 * StepUpData = R
 * PReq = R
 * PRes = R
 * RReq = R
 * RRes = R
 * Erro = R
 */
@property (nonatomic, readonly) NSString *threeDSServerTransID;

/*!
 * @property acsCounterAtoS ACS Counter A to S
 * @brief ACS Counter ACS to SDK
 */
@property (nonatomic, readonly) NSString *acsCounterAtoS;

/*!
 * @property acsTransID ACS Transaction ID
 * @brief Universally Unique transaction identifier assigned by the ACS to identify a single transaction.
 * Must be in the canonical format as defined in IETF RFC 4122. May utilise any of the specified
 * versions if the output meets specified requirements.
 *
 * Source: ACS
 * Length: 36 characters
 * Format: String
 * Device Channel: 01-APP, 02-BRW
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: ARes = R, StepUpRequest = R, StepUpData = R, RReq = R, RRes = R
 */
@property (nonatomic, readonly) NSString *acsTransID;

/*!
 * @property acsHTML ACS HTML
 * @brief HTML provided by the ACS in the StepUpData message. Utilised in the HTML UI type during the Cardholder challenge.
 * This value will be Base64 Encoded prior to being placed into the StepUpData message.
 *
 * Source: ACS
 * Length: Variable, maximum 100KB
 * Format: String
 * Values: Base64 Encoded HTML
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Conditional if ACS upon selection of the HTML UI Type is= 5 (HTML) by
 * the ACS.
 */
@property (nonatomic, readonly) NSString *acsHTML;

@property (nonatomic, readonly) NSString *acsHTMLRefresh;
/*!
 * @property acsUiType ACS UI Type
 * @brief User interface type that the 3DS SDK will render, which includes the specific data mapping and requirements.
 *
 * Source: ACS
 * Length: 1 character
 * Format: Number
 * Possible Values (one of the following):
 * 1 = Text
 * 2 = Single Select
 * 3 = Multi Select
 * 4 = OOB
 * 5 = HTML
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = R
 */
@property (nonatomic, readonly) NSString *acsUiType;

/*!
 * @property challengeAddInfo Challenge Additional Information Text
 * @brief Additional text provided by the ACS/Issuer to Cardholder during the Challenge Message exchange that could not be accommodated in the Challenge Information Text field.
 *
 * Source: ACS
 * Length: Variable, maximum 256 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required based upon the ACS UI format selected.
 */
@property (nonatomic, readonly) NSString *challengeAddInfo;

/*!
 * @property challengeCompletionInd Challenge Completion Indicator
 * @brief Indicator of the state of the ACS challenge cycle and whether the challenge has completed or
 * will require additional messages. Shall be populated in all StepUpData messages to convey the
 * current state of the transaction.
 *
 * Note: If set to Y the ACS will populate the Transaction Status in the StepUpData message.
 * Source: ACS
 * Length: 1 character
 * Format: String
 * Values: Y = Challenge completed and no further challenge message exchanges are required.
 * N = Challenge not completed and there shall be additional challenge
 * message exchanges required.
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = R
 */
@property (nonatomic, readonly) NSString *challengeCompletionInd;

/*!
 * @property challengeInfoHeader Challenge Information Header
 * @brief Header text that for the challenge information screen that is being presented.
 *
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required if ACS UI Type = 1–4.
 */
@property (nonatomic, readonly) NSString *challengeInfoHeader;

/*!
 * @property challengeInfoLabel Challenge Information Label
 * @brief Label to modify the text provided by the Issuer to describe what is
 * being requested from the Cardholder
 *
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required if ACS UI Type = 1–4.
 */
@property (nonatomic, readonly) NSString *challengeInfoLabel;

/*!
 * @property challengeInfoText Challenge Information Text
 * @brief Text provided by the ACS/Issuer to Cardholder during the Challenge Message exchange.
 *
 * Source: ACS
 * Length: Variable, maximum 256 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required if ACS UI Type = 1–4.
 */
@property (nonatomic, readonly) NSString *challengeInfoText;

/*!
 * @property challengeInfoTextIndicator Challenge Info Text Indicator
 * @brief Challenge Information Text Indicator
 */
@property (nonatomic, readonly) NSString *challengeInfoTextIndicator;

/*!
 * @property challengeSelectInfo Challenge Selection Information
 * @brief Selection information that will be presented to the Cardholder if the option is single or
 * multi-select. The variables will be sent in a JSON Array and parsed by the SDK for display in
 * the user interface.
 *
 * Example: "Challenge Selection Information": [{"mobile": "**** **** 123"}, {"email":
 * "s******k**@g***.com"}]
 * Source: ACS
 * Length:  Variable, each name/value pair maximum 45 characters
 * Format: Array
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required if the ACS UI Type = 2 or 3
 */
@property (nonatomic, readonly) NSArray *challengeSelectInfo;

/*!
 * @property expandInfoLabel Expandable Information Label
 * @brief Label displayed to the Cardholder for the content in Expandable Information Label.
 *
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 */
@property (nonatomic, readonly) NSString *expandInfoLabel;

/*!
 * @property expandInfoText Expandable Information Text
 * @brief Label displayed to the Cardholder for the content in Expandable Information Text.
 *
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 */
@property (nonatomic, readonly) NSString *expandInfoText;

/*!
 * @property issuerImage Issuer Image
 * @brief Sent in the initial StepUpData message from the ACS to the 3DS SDK to provide the URL(s) of the
 * Issuer logo or image to be used in the Native UI.
 * Three fully qualified URLs with small, medium and large images to be loaded and cached for
 * use in the current challenge. SDK to select size appropriate for the current device screen
 * resolution.
 *
 * Example:
 * "issuerImage" = {
 * "small":"http://acs.com/small_image.jpg",
 * "medium":"http://acs.com/medium_image.jpg",
 * "large":"http://acs.com/large_image.jpg" }
 * Option 2: May also be "none" if no image is to be displayed.
 * Example:
 * "issuerImage" = "none"
 * Source: ACS
 * Length: Variable, maximum 2048 characters
 * Format: JSON Object
 * Values:
 * Option 1:
 * JSON Object, string, values as follows:
 * "small": Fully qualified URL of small image resource
 * "medium" Fully qualified URL of medium image resource
 * "large" Fully qualified URL of large image resource
 * Option 2:
 * String containing the value "none"
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required on the initial StepUpData message from the ACS, omitted after.
 * Conditional for Native UI.
 */
@property (nonatomic, readonly) CardinalImageUrl *issuerImage;

/*!
 * @property messageExtension Message Extension
 * @brief Data necessary to support requirements not otherwise defined in the 3-D Secure message must
 * be carried in a Message Extension.
 *
 * Source: 3DS Server
 * Length: Variable, maximum 8192 bytes
 * Format: JSON Array of objects
 * Device Channel: 01-APP, 02-BRW
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion:
 * AReq = C, ARes = C, StepUpRequest = C, StepUpData = C, PReq = C, PRes = C, RReq = C, RRes = C
 * Conditional Inclusion: Conditions to be set by each DS.
 */
@property (nonatomic, readonly) NSArray *messageExtension;

/*!
 * @property messageType Message Type
 * @brief Identifies the type of message that is being passed.
 *
 * Source: ACS, DS, 3DS Server, 3DS SDK
 * Length: 4 characters
 * Format: String
 * Values: AReq, ARes, StepUpRequest, StepUpData, PReq, PRes, RReq, RRes, Erro
 * Device Channel: 01-APP, 02-BRW
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: AReq = R, ARes = R, StepUpRequest = R, StepUpData = R, PReq = R,
 * PRes = R, RReq = R, RRes = R, Error = R
 */
@property (nonatomic, readonly) NSString *messageType;

/*!
 * @property messageVersion Message Version
 * @brief Specification version identifier This shall be the version number of the specification
 * utilised by the system creating this message.
 *
 * Source: 3DS Server, DS, ACS, 3DS SDK
 * Length: 5 characters
 * Format: String
 * Values: n.n.n where: "n" represents a numeric digit that relates to the major and minor of
 * the specification version number
 * Device Channel: 01-APP, 02-BRW
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: AReq = R, ARes = R, StepUpRequest = R, StepUpData = R, PReq = R,
 * PRes = R, RReq = R, RRes = R, Error = R
 */
@property (nonatomic, readonly) NSString *messageVersion;

/*!
 * @property oobAppURL OOB App URL
 * @brief Mobile Deep link to an authentication app used in the out-of-band authentication. The App URL
 * will open the appropriate location within the authentication app.
 *
 * Source: ACS
 * Length: Variable, maximum 256 characters
 * Format: String
 * Values: Fully Qualified URL
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required for ACS UI Type = 4 or 5
 */
@property (nonatomic, readonly) NSString *oobAppURL;

/*!
 * @property oobAppLabel OOB App Label
 * @brief Label to be displayed for the link to the OOB App URL.
 * For example:
 * "OOBAppLabel" : "Click here to open Your Bank App"
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 */
@property (nonatomic, readonly) NSString *oobAppLabel;

/*!
 * @property oobContinueLabel OOB Continuation Label
 * @brief Label to be used in the UI for the button that the user selects when they have completed the
 * OOB authentication.
 *
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required when ACS UI Type = 4 in when the Cardholder has selected that
 * option on the device.
 */
@property (nonatomic, readonly) NSString *oobContinueLabel;

/*!
 * @property psImage PSImage
 * @brief Sent in the initial StepUpData message from the ACS to the 3DS SDK to provide the URL(s) of the DS
 * logo or image to be used in the Native UI
 *
 * Option 1: Three fully qualified URLs with small, medium and large images to be loaded and
 * cached for use in the current challenge. SDK to select size appropriate for the current
 * device screen resolution.
 * Example:
 * "psImage" = {
 * "small":"http://ds.com/small_image.jpg",
 * "medium":"http://ds.com/medium_image.jpg",
 * "large":"http://ds.com/large_image.jpg" }
 * Source: ACS
 * Length: Variable, maximum 2048 characters
 * Format: JSON object
 * Values:
 * Option 1:
 * JSON Object, string values as follows:
 * "small": Fully qualified URL of small image resource
 * "medium": Fully qualified URL of medium image resource
 * "large": Fully qualified URL of large image resource
 * Option 2:
 * String containing the value "none"
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required on the intial StepUpData message from the ACS, omitted after.
 * Conditional for ACS UI Type = 1–4.
 */
@property (nonatomic, readonly) CardinalImageUrl *psImage;

/*!
 * @property resendInformationLabel Resend Information Label
 * @brief Label to be used in the UI for the button that the user selects when they would like to have
 * the authentication information resent.
 *
 * Source: ACS
 * Length: Variable maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required when the ACS UI Type = 1, 2, or 3
 */
@property (nonatomic, readonly) NSString *resendInformationLabel;

/*!
 * @property sdkTransID SDK Transaction ID
 * @brief Universally unique transaction identifier assigned by the 3DS SDK to identify a single
 * transaction.
 *
 * Must be in the canonical format as defined in IETF RFC 4122. This may utilise any of the
 * specified versions as long as the output meets specified requirements.
 * Source: 3DS SDK (sent via 3DS Server)
 * Length: 36 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: AReq = R, ARes = R, StepUpRequest = R, StepUpData = R
 */
@property (nonatomic, readonly) NSString *sdkTransID;

/*!
 * @property submitAuthenticationLabel Submit Authentication Label
 * @brief Label to be used in the UI for the button that the user selects when they have completed the
 * authentication. This is not used for OOB authentication.
 *
 * Source: ACS
 * Length: Variable maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required when the ACS UI Type = 1, 2, or 3
 */
@property (nonatomic, readonly) NSString *submitAuthenticationLabel;

/*!
 * @property transStatus Transaction Status
 * @brief Indicates whether a transaction qualifies as an authenticated transaction.
 *
 * Note: The StepUpData message can contain only a value of Y or N.
 * Note: If the IReq is included in the message, the Transaction Status must be U.
 * Source: ACS
 * Length: 1 character
 * Format: String
 * Values: Y = Authentication Successful; All data needed for authorisation, including the
 * Authentication Value, is included in the message for 01-PA
 * N = Not Authenticated; Transaction denied
 * U = Authentication Could Not Be Performed; Technical or other problem, as indicated in ARes
 * or StepUpData
 * A = Attempts Processing Performed; Not authenticated, but a proof of attempted authentication
 * is provided. All data needed for authorisation including the Authentication Value is included
 * in the message for 01-PA.
 * C = Challenge Required; Additional authentication is required using the StepUpRequest/StepUpData.
 * R = Authentication Rejected; Issuer is rejecting authentication and request that
 * authorisation not be attempted.
 * Device Channel: 01-APP, 02-BRW
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: ARes = R, RReq = R, StepUpData = C
 * Conditional Inclusion: This data element only present in the final StepUpData message.
 */
@property (nonatomic, readonly) NSString *transStatus;

/*!
 * @property whyInfoLabel Why Information Label
 * @brief Label to be displayed to the Cardholder for the "why" information section.
 *
 * Source: ACS
 * Length: Variable, maximum 45 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required based upon the ACS UI format selected.
 */
@property (nonatomic, readonly) NSString *whyInfoLabel;

/*!
 * @property whyInfoText Why Information Text
 * @brief Text provided by the Issuer to be displayed to the Cardholder to explain why the Cardholder
 * is being asked to perform the authentication task.
 *
 * Source: ACS
 * Length: Variable, maximum 256 characters
 * Format: String
 * Device Channel: 01-APP
 * Message Category: 01-PA, 02-NPA
 * Message Inclusion: StepUpData = C
 * Conditional Inclusion: Required based upon the ACS UI format selected.
 */
@property (nonatomic, readonly) NSString *whyInfoText;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
