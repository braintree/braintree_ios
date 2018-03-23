#import <Foundation/Foundation.h>
#import "BTAPIClient.h"
#import "BTPaymentMethodNonce.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for tokenization service errors.
 */
extern NSString * const BTTokenizationServiceErrorDomain;

/**
 Key for app switch delegate.
 */
extern NSString * const BTTokenizationServiceAppSwitchDelegateOption;

/**
 Key for view presenting delegate.
 */
extern NSString * const BTTokenizationServiceViewPresentingDelegateOption;

/**
 Key for PayPal scopes.
 */
extern NSString * const BTTokenizationServicePayPalScopesOption;

/**
 Key for amount.
 */
extern NSString * const BTTokenizationServiceAmountOption;

/**
 Key for nonce.
 */
extern NSString * const BTTokenizationServiceNonceOption;

/**
 Error codes associated with `BTTokenizationService`.
 */
typedef NS_ENUM(NSInteger, BTTokenizationServiceError) {
    /// Unknown error
    BTTokenizationServiceErrorUnknown = 0,

    /// Type not registered
    BTTokenizationServiceErrorTypeNotRegistered,
};

/**
 A tokenization service that supports registration of tokenizers at runtime.

 `BTTokenizationService` provides access to tokenization services from payment options
 (e.g. `BTPayPalDriver`) without introducing compile-time dependencies on the frameworks.
*/
@interface BTTokenizationService : NSObject

/**
 The singleton instance of the tokenization service
*/
+ (instancetype)sharedService;

/**
 Registers a block to execute for a given type when `tokenizeType:withAPIClient:completion:` or`tokenizeType:options:withAPIClient:completion:` are invoked.

 @param type A type string to identify the tokenization block. Providing a type that has already
        been registered will overwrite the previously registered tokenization block.
 @param tokenizationBlock The tokenization block to register for a type.
*/
- (void)registerType:(NSString *)type withTokenizationBlock:(void(^)(BTAPIClient *apiClient, NSDictionary * _Nullable options, void(^)(BTPaymentMethodNonce * _Nullable paymentMethodNonce, NSError * _Nullable error)))tokenizationBlock;

/**
 Indicates whether a type has been registered with a valid tokenization block.
*/
- (BOOL)isTypeAvailable:(NSString *)type;

/**
 Perform tokenization for the given type. This will execute the tokenization block that has been registered for the type.

 @param type The tokenization type to perform
 @param apiClient The API client to use when performing tokenization.
 @param completion The completion block to invoke when tokenization has completed.
*/
- (void)tokenizeType:(NSString *)type
       withAPIClient:(BTAPIClient *)apiClient
          completion:(void(^)(BTPaymentMethodNonce * _Nullable paymentMethodNonce, NSError * _Nullable error))completion;

/**
 Perform tokenization for the given type. This will execute the tokenization block that has been registered for the type.

 @param type The tokenization type to perform
 @param options A dictionary of data to use when invoking the tokenization block. This can be
        used to pass data into a tokenization client/driver, e.g. credit card raw details.
 @param apiClient The API client to use when performing tokenization.
 @param completion The completion block to invoke when tokenization has completed.
*/
- (void)tokenizeType:(NSString *)type
             options:(nullable NSDictionary<NSString *, id> *)options
       withAPIClient:(BTAPIClient *)apiClient
          completion:(void(^)(BTPaymentMethodNonce * _Nullable paymentMethodNonce, NSError * _Nullable error))completion;

/**
 An array of all tokenization types
 */
@property (nonatomic, readonly, strong) NSArray <NSString *> *allTypes;

@end

NS_ASSUME_NONNULL_END
