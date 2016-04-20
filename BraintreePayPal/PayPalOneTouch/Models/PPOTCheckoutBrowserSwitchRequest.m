//
//  PPOTCheckoutBrowserSwitchRequest.m
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import "PPOTCheckoutBrowserSwitchRequest.h"
#import "PPOTAppSwitchUtil.h"
#import "PPOTPersistentRequestData.h"
#import "PPOTTime.h"
#import "PPOTString.h"
#import "PPOTMacros.h"

// TODO: have a factory/builder/json reader of sandbox, mock, etc

@interface PPOTCheckoutBrowserSwitchRequest ()
@property (nonatomic, readwrite) NSString *msgID;
@end

@implementation PPOTCheckoutBrowserSwitchRequest

- (NSURL *)encodedURL {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.approvalURL];
    NSString *successURL;
    NSString *cancelURL;
    [PPOTAppSwitchUtil redirectURLsForCallbackURLScheme:self.callbackURLScheme withReturnURL:&successURL withCancelURL:&cancelURL];

    NSString *originalQuery = urlComponents.query;
    if ([originalQuery length] > 0) {
        originalQuery = [NSString stringWithFormat:@"%@&", originalQuery];
    } else {
        originalQuery = @"";
    }
    NSString *finalQuery = [NSString stringWithFormat:@"%@%@=%@&%@=%@&%@=%@",
                            originalQuery,
                            kPPOTAppSwitchXSourceKey, [PPOTAppSwitchUtil bundleId],
                            kPPOTAppSwitchXSuccessKey, successURL,
                            kPPOTAppSwitchXCancelKey, cancelURL];
    urlComponents.query = finalQuery;

    return urlComponents.URL;
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
