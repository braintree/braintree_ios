@import Foundation;
#import "BTAppSwitching.h"
#import "BTPaymentProvider.h"

@interface BTAppSwitch : NSObject

@property (nonatomic, readwrite, copy) NSString *returnURLScheme;

+ (instancetype)sharedInstance;

- (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)addAppSwitching:(id<BTAppSwitching>)appSwitching forPaymentProvider:(BTPaymentProviderType)type;
- (void)removeAppSwitchingForPaymentProvider:(BTPaymentProviderType)type;
- (id <BTAppSwitching>)appSwitchingForPaymentProvider:(BTPaymentProviderType)type;

@end
