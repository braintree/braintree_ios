#import "BTPayPalRequestFactory.h"
#import "PayPalOneTouchCore.h"
#import "PayPalOneTouchRequest.h"

#pragma mark - FakePayPalOneTouchCoreResult

@interface FakePayPalOneTouchCoreResult : PayPalOneTouchCoreResult
@property (nonatomic, strong, nullable) NSError *cannedError;
@property (nonatomic, assign) PayPalOneTouchResultType cannedType;
@property (nonatomic, assign) PayPalOneTouchRequestTarget cannedTarget;
@end

#pragma mark - FakePayPalOneTouchCore

@interface FakePayPalOneTouchCore : PayPalOneTouchCore
+ (nullable FakePayPalOneTouchCoreResult *)cannedResult;
+ (void)setCannedResult:(nullable FakePayPalOneTouchCoreResult *)result;
+ (BOOL)cannedIsWalletAppAvailable;
+ (void)setCannedIsWalletAppAvailable:(BOOL)isWalletAppAvailable;
@end

#pragma mark - FakePayPalCheckoutRequest

@interface FakePayPalCheckoutRequest : PayPalOneTouchCheckoutRequest
@property (nonatomic, strong, nullable) NSError *cannedError;
@property (nonatomic, assign) BOOL cannedSuccess;
@property (nonatomic, assign) PayPalOneTouchRequestTarget cannedTarget;
@property (nonatomic, strong, nullable) NSString *cannedMetadataId;
@property (nonatomic, assign) BOOL appSwitchPerformed;
@end

#pragma mark - FakePayPalAuthorizationRequest

@interface FakePayPalAuthorizationRequest : PayPalOneTouchAuthorizationRequest
@property (nonatomic, strong, nullable) NSError *cannedError;
@property (nonatomic, assign) BOOL cannedSuccess;
@property (nonatomic, assign) PayPalOneTouchRequestTarget cannedTarget;
@property (nonatomic, strong, nullable) NSString *cannedMetadataId;
@property (nonatomic, assign) BOOL appSwitchPerformed;
@property (nonatomic, strong, nullable) NSURL *cannedURL;
@end

#pragma mark - FakePayPalBillingAgreementRequest

@interface FakePayPalBillingAgreementRequest : PayPalOneTouchBillingAgreementRequest
@property (nonatomic, strong, nullable) NSError *cannedError;
@property (nonatomic, assign) BOOL cannedSuccess;
@property (nonatomic, assign) PayPalOneTouchRequestTarget cannedTarget;
@property (nonatomic, strong, nullable) NSString *cannedMetadataId;
@property (nonatomic, assign) BOOL appSwitchPerformed;
@end

#pragma mark - FakePayPalRequestFactory

@interface FakePayPalRequestFactory : BTPayPalRequestFactory
@property (nonatomic, strong, nonnull) FakePayPalCheckoutRequest *checkoutRequest;
@property (nonatomic, strong, nonnull) FakePayPalAuthorizationRequest *authorizationRequest;
@property (nonatomic, strong, nonnull) FakePayPalBillingAgreementRequest *billingAgreementRequest;
@property (nonatomic, strong, nullable) NSSet<NSObject *> *lastScopeValues;
@end
