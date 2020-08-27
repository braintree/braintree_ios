#import "BTCardClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient ()

/**
 Exposed for testing to get the instance of BTAPIClient
*/
@property (nonatomic, strong, readwrite) BTAPIClient *apiClient;

/**
 Convenience helper method for creating friendlier, more human-readable userInfo dictionaries for 422 HTTP errors
*/
+ (NSDictionary *)validationErrorUserInfo:(NSDictionary *)userInfo;

/**
 The `PPDataCollector` class string, exposed internally for injecting test doubles for unit tests
 */
+ (void)setPayPalDataCollectorClassString:(nonnull NSString *)payPalDataCollectorClassString;

/**
 The `PPDataCollector` class, exposed internally for injecting test doubles for unit tests
 */
+ (void)setPayPalDataCollectorClass:(nonnull Class)payPalDataCollectorClass;

@end

NS_ASSUME_NONNULL_END
