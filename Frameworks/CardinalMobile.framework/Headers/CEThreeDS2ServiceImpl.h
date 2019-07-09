//
//  CEThreeDS2ServiceImpl.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreeDS2Service.h"

@class ConfigParameters;
@class UiCustomization;

/**
 * The CEThreeDS2ServiceImpl interface confronts to ThreeDS2ServiceImpl protocol and is the main 3DS SDK interface.
 * It shall provide methods to process transactions.
 */

@interface CEThreeDS2ServiceImpl : NSObject<ThreeDS2Service>

@end
