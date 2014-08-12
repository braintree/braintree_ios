#import <Foundation/Foundation.h>

@class BTClient, BTPaymentMethod;
@protocol BTAppSwitchHandlerDelegate;

@interface BTAppSwitchHandler : NSObject

@property (nonatomic, copy) NSString *appSwitchCallbackURLScheme;

@property (nonatomic, readonly, strong) BTClient *client;

@property (nonatomic, weak) id<BTAppSwitchHandlerDelegate>delegate;

+ (instancetype)sharedHandler;

- (BOOL)initiateAuthWithClient:(BTClient *)client delegate:(id<BTAppSwitchHandlerDelegate>)delegate;

- (BOOL)handleAppSwitchURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end


@protocol BTAppSwitchHandlerDelegate <NSObject>

@optional

- (void)appSwitchHandlerWillCreatePaymentMethod:(BTAppSwitchHandler *)appSwitchHandler;

@required

- (void)appSwitchHandler:(BTAppSwitchHandler *)appSwitchHandler didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

- (void)appSwitchHandler:(BTAppSwitchHandler *)appSwitchHandler didFailWithError:(NSError *)error;

- (void)appSwitchHandlerAuthenticatorAppDidCancel:(BTAppSwitchHandler *)appSwitchHandler;

@end
