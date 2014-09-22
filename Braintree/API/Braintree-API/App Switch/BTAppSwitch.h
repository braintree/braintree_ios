@import Foundation;
#import "BTAppSwitching.h"

@interface BTAppSwitch : NSObject

@property (nonatomic, readwrite, copy) NSString *returnURLScheme;

+ (instancetype)sharedInstance;

- (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)addAppSwitching:(id<BTAppSwitching>)appSwitching;
- (void)removeAppSwitching:(id<BTAppSwitching>)appSwitching;

@end
