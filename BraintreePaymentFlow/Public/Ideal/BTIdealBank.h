#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 @brief iDEAL issuing bank.
  */
@interface BTIdealBank : NSObject

/**
 @brief Initialize a BTIdealBank.
 
 @return A BTIdealBank.
 */
- (instancetype)initWithCountryCode:(NSString *)countryCode issuerId:(NSString *)issuerId name:(NSString *)name imageUrl:(NSString *)imageUrl;

/**
 @brief The country code of the bank.
 */
@property (nonatomic, readonly, copy) NSString *countryCode;

/**
 @brief The ID of the issuing bank.
 
 @discussion See `BTPaymentFlowDriver+Ideal` and `BTIdealBank`.
 */
@property (nonatomic, readonly, copy) NSString *issuerId;

/**
 @brief The bank name, appropriate to display in UI.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 @brief The URL of an image associated with the bank, appropriate to display in UI.
 */
@property (nonatomic, readonly, copy) NSString *imageUrl;

@end

NS_ASSUME_NONNULL_END
