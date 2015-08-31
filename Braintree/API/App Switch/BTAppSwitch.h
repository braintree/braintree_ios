#import <Foundation/Foundation.h>
#import "BTAppSwitching.h"

/// Type of payment app
typedef NS_ENUM(NSInteger, BTAppType) {
    BTAppTypePayPal = 0,
    BTAppTypeVenmo,
    BTAppTypeApplePay,
    BTAppTypeCoinbase,
};

NS_ASSUME_NONNULL_BEGIN

@interface BTAppSwitch : NSObject

@property (nonatomic, readwrite, copy) NSString *returnURLScheme;

+ (instancetype)sharedInstance;

- (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

- (void)addAppSwitching:(id<BTAppSwitching>)appSwitching forApp:(BTAppType)type;
- (void)removeAppSwitchingForApp:(BTAppType)type;
- (id <BTAppSwitching>)appSwitchingForApp:(BTAppType)type;

@end

NS_ASSUME_NONNULL_END
