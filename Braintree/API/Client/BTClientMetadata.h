#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTClientMetadataSourceType) {
    BTClientMetadataSourcePayPalSDK,
    BTClientMetadataSourcePayPalApp,
    BTClientMetadataSourceVenmoApp,
    BTClientMetadataSourceForm,
    BTClientMetadataSourceUnknown,
    BTClientMetadataSourceCoinbaseApp,
    BTClientMetadataSourceCoinbaseBrowser,
};

typedef NS_ENUM(NSInteger, BTClientMetadataIntegrationType) {
    BTClientMetadataIntegrationCustom,
    BTClientMetadataIntegrationDropIn,
    BTClientMetadataIntegrationUnknown
};

@interface BTClientMetadata : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, assign, readonly) BTClientMetadataIntegrationType integration;
@property (nonatomic, assign, readonly) BTClientMetadataSourceType source;

@property (nonatomic, copy, readonly) NSString *integrationString;
@property (nonatomic, copy, readonly) NSString *sourceString;

/// Auto-generated UUID
@property (nonatomic, copy, readonly) NSString *sessionId;

@end

@interface BTClientMutableMetadata : BTClientMetadata

- (void)setIntegration:(BTClientMetadataIntegrationType)integration;
- (void)setSource:(BTClientMetadataSourceType)source;
- (void)setSessionId:(NSString *)sessionId;

@end
