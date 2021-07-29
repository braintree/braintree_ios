//
//  NSObject+MagnesSystemConfigUtils.h
//  PPRiskMagnes
//
//  Created by Mahalingam, Omkumar on 9/13/18.
//  Copyright © 2018 PayPal Risk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MagnesSystemConfigUtils : NSObject

+ (NSString *) getCPUType;
+ (NSString *) getCPUName;
+ (NSString *) getHardwareModel;
+ (NSString *) getKernelVersion;

@end
