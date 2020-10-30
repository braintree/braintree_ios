#import <Foundation/Foundation.h>

/**
 Source of the metadata
 */
typedef NS_ENUM(NSInteger, BTClientMetadataSourceType) {
    /// Unknown source
    BTClientMetadataSourceUnknown = 0,

    /// PayPal app
    BTClientMetadataSourcePayPalApp,

    /// PayPal browser
    BTClientMetadataSourcePayPalBrowser,

    /// Venmo app
    BTClientMetadataSourceVenmoApp,

    /// Form
    BTClientMetadataSourceForm,
};

/**
 Integration types
 */
typedef NS_ENUM(NSInteger, BTClientMetadataIntegrationType) {
    /// Custom
    BTClientMetadataIntegrationCustom,

    /// Drop-in
    BTClientMetadataIntegrationDropIn,

    /// Drop-in 2
    BTClientMetadataIntegrationDropIn2,

    /// Unknown integration
    BTClientMetadataIntegrationUnknown
};

NS_ASSUME_NONNULL_BEGIN

/**
 Represents the metadata associated with a session for posting along with payment data during tokenization

 When a payment method is tokenized, the client api accepts parameters under
 _meta which are used to determine where payment data originated.

 In general, this data may evolve and be used in different ways by different
 integrations in a single app. For example, if both Apple Pay and drop in are
 used. In this case, the source and integration may change over time, while
 the sessionId should remain constant. To achieve this, users of this class
 should use `mutableCopy` to create a new copy based on the existing session
 and then update the object as needed.
*/
@interface BTClientMetadata : NSObject <NSCopying, NSMutableCopying>

/**
 Integration type
 */
@property (nonatomic, assign, readonly) BTClientMetadataIntegrationType integration;

/**
 Integration source
 */
@property (nonatomic, assign, readonly) BTClientMetadataSourceType source;

/**
 Auto-generated UUID
*/
@property (nonatomic, copy, readonly) NSString *sessionId;

#pragma mark Derived Properties

/**
 String representation of the integration
 */
@property (nonatomic, copy, readonly) NSString *integrationString;

/**
 String representation of the source
 */
@property (nonatomic, copy, readonly) NSString *sourceString;

/**
 Additional metadata parameters
 */
@property (nonatomic, strong, readonly) NSDictionary *parameters;

@end

/**
 Mutable `BTClientMetadata`
 */
@interface BTMutableClientMetadata : BTClientMetadata

/**
 Integration type
 @param integration The BTClientMetadataIntegrationType
 */
- (void)setIntegration:(BTClientMetadataIntegrationType)integration;

/**
 Integration source
 @param source The BTClientMetadataSourceType
 */
- (void)setSource:(BTClientMetadataSourceType)source;

/**
 Auto-generated UUID
 @param sessionId A string for the session
 */
- (void)setSessionId:(NSString *)sessionId;

@end

NS_ASSUME_NONNULL_END
