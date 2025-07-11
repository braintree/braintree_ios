/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>

/// :nodoc:
@interface VisaMessageHandler : NSObject
- (instancetype)init NS_UNAVAILABLE;

@property (class, nonatomic, readonly) NSString *configureVisaCheckoutPlugin
DEPRECATED_MSG_ATTRIBUTE("Please add the 'visaMessage' handler instead");
@property (class, nonatomic, readonly) NSString *launchVisaCheckout
DEPRECATED_MSG_ATTRIBUTE("Please add the 'visaMessage' handler instead");

@property (class, nonatomic, readonly) NSString *visaMessage;
@end
