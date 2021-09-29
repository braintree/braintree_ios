
#import <Foundation/Foundation.h>

#import <AuthenticationServices/AuthenticationServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTWebAuthenticator : NSObject
@property (nonatomic, weak) id<ASWebAuthenticationPresentationContextProviding> presentationContextProvider API_AVAILABLE(ios(13));

- (void)authenticateWithURL:(NSURL*)url callbackURLScheme:(NSString *)callbackURLScheme completion:(void (^)(NSURL * _Nullable callbackURL, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
