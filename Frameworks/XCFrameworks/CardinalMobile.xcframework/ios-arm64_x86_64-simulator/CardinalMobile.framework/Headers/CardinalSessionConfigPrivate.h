//
//  CardinalSessionConfigPrivate.h
//  CardinalMobileSDK
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardinalSessionConfiguration.h"

extern NSURL * _Nonnull kCCAConfigDefaultURL; // Release == ProductionURL; Debug == SandboxURL
extern NSURL * _Nonnull kCCAConfigStagingURL;
extern NSURL * _Nonnull kCCAConfigProductionURL;

#define kCCAConfigTimeoutInMillisecondsMIN 0
#define kCCAConfigTimeoutInMillisecondsMAX 60000


//For Debug Build Minimum ChallengeScreen TimeOut is set to 0 minutes so that Timeout TestCases don't take too long to complete.
#if DEBUG
#define kCCAConfigChallengeTimeoutInMinuteMIN 0
#else
#define kCCAConfigChallengeTimeoutInMinuteMIN 5
#endif

@protocol CardinalSessionConfigInternalType <NSObject, NSCopying>

@property (nonatomic, readonly, nonnull) NSURL *deploymentEnvironmentURL;
@property (nonatomic, readonly) NSTimeInterval timeoutInSeconds;
@property (nonatomic, readonly) NSTimeInterval sdkMaxTimeoutInSeconds;

#if DEBUG
// Make addition declarations here for unit-testing and debugging properties that must be compiled out of the production SDK.
@optional
#endif

@end

@protocol CardinalSessionConfigType <CardinalSessionConfigInternalType>

// Mirror public API so we can refer to all the fields in CardinalSessionConfig via its protocol
@property (nonatomic, assign) CardinalSessionEnvironment deploymentEnvironment;
@property (nonatomic, assign) NSUInteger timeout;
@property (nonatomic, copy, nullable) NSURL *proxyServerURL;

//@property (nonatomic, copy, nullable) NSArray<NSString*> *uiTypeStrings;
//@property (nonatomic, copy, nullable) NSArray<NSString*> *renderTypeStrings;

@end


@interface CardinalSessionConfiguration () <CardinalSessionConfigType> // Private

- (NSString*_Nonnull) getStringEnvironment;
- (NSString*_Nonnull) getStringRenderType;

@end
