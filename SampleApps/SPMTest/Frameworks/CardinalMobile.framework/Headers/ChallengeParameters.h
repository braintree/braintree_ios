//
//  ChallengeParameters.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The ChallengeParameters class holds the parameters that are required to conduct the challenge process.
 */
@interface ChallengeParameters : NSObject

/**
 * @property threeDSServerTransactionID Transaction identifier assigned by the 3DS Server to uniquely identify a single transaction.
 */
@property (nonatomic, strong) NSString* threeDSServerTransactionID;

/**
 * @property acsTransactionID Transaction ID assigned by the ACS to uniquely identify a single transaction.
 */
@property (nonatomic, strong) NSString* acsTransactionID;

/**
 * @property acsRefNumber  EMVCo assigns the ACS this identifier after running the EMV 3-D Secure Testing and Approvals process on the ACS.
 */
@property (nonatomic, strong) NSString* acsRefNumber;

/**
 * @property acsSignedContent ACS signed content. This data includes the ACS URL, ACS ephemeral public key, and SDK ephemeral public key.
 */
@property (nonatomic, strong) NSString* acsSignedContent;

/**
 * @property threeDSRequestorAppURL 3DS Requestor App URL
 */
@property (nonatomic, strong) NSString* threeDSRequestorAppURL;

/**
 * The get3DSServerTransactionID method returns the 3DS Server Transaction ID.
 * @return NSString
 */
- (NSString *) get3DSServerTransactionID;

/**
 * The getAcsTransactionID method returns the ACS Transaction ID.
 * @return NSString
 */
- (NSString *) getAcsTransactionID;

/**
 * The getAcsRefNumber method returns the ACS Reference Number.
 * @return NSString
 */
- (NSString *) getAcsRefNumber;

/**
 * The getAcsSignedContent method returns the ACS signed content.
 * @return NSString
 */
- (NSString *) getAcsSignedContent;

/**
 * The getThreeDSRequestorAppURL method returns the 3DS Requestor App URL.
 * @return NSString
 */
- (NSString *) getThreeDSRequestorAppURL;

@end
