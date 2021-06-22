//
//  KountAnalyticsViewController.h
//  KountDataCollector
//
//  Created by Vamsi Krishna on 07/08/20.
//  Copyright © 2020 Kount Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "KDataCollector.h"

NS_ASSUME_NONNULL_BEGIN

@interface KountAnalyticsViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UISearchBarDelegate> {

}

+ (id)sharedInstance;
+ (void)setColorWellButtonType;
- (NSString *)getColorWellButtonType;
+ (NSString *)getAppSessionID;
- (BOOL)checkIsDeviceJailbroken;
- (void)appear;
- (void)disappear;
- (int64_t)getEpochTime;
- (void)storeDeletionTime;
- (void)storeStartingTime;
- (void)msDifferenceBetweenCharacter;
- (void)allMsDifferenceBetweenKeys;
- (void)assignInputData;
- (void)deviceDidRotate:(NSNotification *)notification;
- (void)collectBatteryData;
- (void)getBatteryState;
- (void)getBatteryLevel;
- (void)getLowPowerModeStatus;
- (void)didChangeBatteryState:(NSNotification *)notification;
- (void)didChangeBatteryLevel:(NSNotification *)notification;
- (void)didChangePowerMode:(NSNotification *)notification;
- (void)assignBatteryData;
- (void)getDeviceOrientationData;
- (void)collectDeviceOrientationData;
- (void)assignDeviceOrientationData;
- (void)checkForDeviceMotion;
- (void)collect:(NSString *)sessionID analyticsSwitch:(BOOL)analyticsData completion:(nullable void (^)(NSString *_Nonnull sessionID, BOOL success, NSError *_Nullable error))completionBlock;
- (NSString *)getSessionID;
- (void)createJsonObjectFormat;
- (void)storeLogInEvents:(BOOL)logInStatus;
- (void)assignFormData;
- (void)setEnvironmentForAnalytics:(KEnvironment)env;
- (void)registerBackgroundTask;
- (void)appInBackground;

@end

NS_ASSUME_NONNULL_END

