@import Foundation;


typedef NS_ENUM(NSInteger, BraintreeDemoTransactionServiceEnvironment) {
    BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant = 0,
    BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant = 1,
};

typedef NS_ENUM(NSInteger, BraintreeDemoTransactionServiceThreeDSecureRequiredStatus) {
    BraintreeDemoTransactionServiceThreeDSecureRequiredStatusDefault = 0,
    BraintreeDemoTransactionServiceThreeDSecureRequiredStatusRequired = 1,
    BraintreeDemoTransactionServiceThreeDSecureRequiredStatusNotRequired = 2,
};

@interface BraintreeDemoSettings : NSObject

+ (BraintreeDemoTransactionServiceEnvironment)currentEnvironment;
+ (BOOL)threeDSecureEnabled;
+ (BraintreeDemoTransactionServiceThreeDSecureRequiredStatus)threeDSecureRequiredStatus;
+ (BOOL)useModalPresentation;
+ (BOOL)customerPresent;
+ (NSString *)customerIdentifier;

@end
