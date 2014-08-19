//
//  BTVenmoAppSwitchURL.h
//  Braintree
//
//  Created by Mickey Reiss on 8/12/14.
//
//

#import <Foundation/Foundation.h>

@interface BTVenmoAppSwitchURL : NSObject

+ (BOOL)isAppSwitchAvailable;
+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID;

@end
