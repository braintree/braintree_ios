//
//  PPOTCheckoutAppSwitchRequest.m
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import "PPOTCheckoutAppSwitchRequest.h"
#if __has_include("PPOTMacros.h")
#import "PPOTMacros.h"
#else
#import <PayPalUtils/PPOTMacros.h>
#endif

@implementation PPOTCheckoutAppSwitchRequest

- (NSDictionary *)payloadDictionary {

    NSMutableDictionary *payload = [[super payloadDictionary] mutableCopy];

    payload[kPPOTAppSwitchAppGuidKey] = self.appGuid;
    payload[kPPOTAppSwitchWebURLKey] = self.approvalURL;

    return payload;
}

@end
