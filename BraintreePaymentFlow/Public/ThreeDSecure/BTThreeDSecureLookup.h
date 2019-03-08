#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#if __has_include("BraintreeCard.h")
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCardNonce.h>
#endif
#import "BTPaymentFlowResult.h"
#import "BTThreeDSecureResult.h"

@interface BTThreeDSecureLookup : BTPaymentFlowResult

@property (nonatomic, copy) NSString *PAReq;
@property (nonatomic, copy) NSString *MD;
@property (nonatomic, copy) NSURL *acsURL;
@property (nonatomic, copy) NSURL *termURL;
@property (nonatomic, copy) NSString *threeDSecureVersion;
@property (readonly, nonatomic) BOOL isThreeDSecureVersion2;
@property (nonatomic, copy) NSString *transactionId;
@property (nonatomic, strong) BTThreeDSecureResult *threeDSecureResult;

/**
 Initialize a BTThreeDSecureLookup

 @param JSON BTJSON used to initialize the BTThreeDSecureLookup
 */
- (instancetype)initWithJSON:(BTJSON *)JSON;

- (BOOL)requiresUserAuthentication;

@end
