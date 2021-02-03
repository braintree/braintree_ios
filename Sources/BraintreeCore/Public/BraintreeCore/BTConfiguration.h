#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTJSON.h>
#else
#import <BraintreeCore/BTJSON.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information specific to a merchant's Braintree integration
 */
@interface BTConfiguration : NSObject

/**
 Used to initialize a `BTConfiguration`
 
 @param json The `BTJSON` to initialize with.
 */
- (instancetype)initWithJSON:(BTJSON *)json NS_DESIGNATED_INITIALIZER;

/**
 The merchant account's configuration as a `BTJSON` object
*/
@property (nonatomic, readonly, strong) BTJSON *json;

/**
 The environment (production or sandbox)
 */
@property (nonatomic, nullable, readonly, copy) NSString *environment;

#pragma mark - Undesignated initializers (do not use)

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithJSON: instead.")));

@end

NS_ASSUME_NONNULL_END
