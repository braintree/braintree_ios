//
//  PPOTCheckoutBrowserSwitchRequest.m
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <PayPalOneTouch/PPOTCheckoutBrowserSwitchRequest.h>
#import <PayPalOneTouch/PPOTAppSwitchUtil.h>
#import <PayPalOneTouch/PPOTPersistentRequestData.h>
#import <PayPalUtils/PPOTTime.h>
#import <PayPalUtils/PPOTString.h>
#import <PayPalUtils/PPOTMacros.h>

// TODO: have a factory/builder/json reader of sandbox, mock, etc

@interface PPOTCheckoutBrowserSwitchRequest ()
@property (nonatomic, readwrite) NSString *msgID;
@end

@implementation PPOTCheckoutBrowserSwitchRequest

- (NSURL *)encodedURL {
    return [NSURL URLWithString:self.approvalURL];
}

- (void)addDataToPersistentRequestDataDictionary:(NSMutableDictionary *)requestDataDictionary {
    [super addDataToPersistentRequestDataDictionary:requestDataDictionary];

    NSString *queryString = [self.approvalURL componentsSeparatedByString:@"?"][1];
    NSDictionary *queryDictionary = [PPOTAppSwitchUtil parseQueryString:queryString];
    NSString *hermesToken = queryDictionary[kPPOTAppSwitchHermesTokenKey];
    if (hermesToken == nil) {
        hermesToken = queryDictionary[kPPOTAppSwitchHermesBATokenKey];
    }
    requestDataDictionary[kPPOTRequestDataDataDictionaryHermesTokenKey] = FORCE_VALUE_OR_NULL(hermesToken);
    requestDataDictionary[kPPOTRequestDataDataDictionaryEnvironmentKey] = FORCE_VALUE_OR_NULL(self.environment);
}

@end
