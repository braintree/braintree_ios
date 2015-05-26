#import "BTClientMetadata.h"

@interface BTClientMetadata () {
    @protected
    BTClientMetadataIntegrationType _integration;
    BTClientMetadataSourceType _source;
    NSString *_sessionId;
}
@end

@interface BTClientMutableMetadata ()

@property (nonatomic, copy) NSString *sessionId;

@end

@implementation BTClientMetadata

- (instancetype)init {
    self = [super init];
    if (self) {
        _integration = BTClientMetadataIntegrationCustom;
        _source = BTClientMetadataSourceUnknown;
        _sessionId = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BTClientMetadata *copiedMetadata = [[BTClientMetadata allocWithZone:zone] init];
    copiedMetadata->_integration = _integration;
    copiedMetadata->_source = _source;
    copiedMetadata->_sessionId = _sessionId;
    return copiedMetadata;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    BTClientMutableMetadata *mutableMetadata = [[BTClientMutableMetadata allocWithZone:zone] init];
    mutableMetadata.integration = _integration;
    mutableMetadata.source = _source;
    mutableMetadata.sessionId = _sessionId;
    return mutableMetadata;
}

- (NSString *)integrationString {
    return [[self class] integrationToString:self.integration];
}

- (NSString *)sourceString {
    return [[self class] sourceToString:self.source];
}

#pragma mark Internal helpers

+ (NSString *)integrationToString:(BTClientMetadataIntegrationType)integration {
    switch (integration) {
        case BTClientMetadataIntegrationCustom:
            return @"custom";
        case BTClientMetadataIntegrationDropIn:
            return @"dropin";
        default:
            return @"unknown";
    }
}

+ (NSString *)sourceToString:(BTClientMetadataSourceType)source {
    switch (source) {
        case BTClientMetadataSourcePayPalSDK:
            return @"paypal-sdk";
        case BTClientMetadataSourcePayPalApp:
            return @"paypal-app";
        case BTClientMetadataSourceVenmoApp:
            return @"venmo-app";
        case BTClientMetadataSourceForm:
            return @"form";
        case BTClientMetadataSourceCoinbaseApp:
            return @"coinbase-app";
        case BTClientMetadataSourceCoinbaseBrowser:
            return @"coinbase-browser";
        default:
            return @"unknown";
    }
}

@end


@implementation BTClientMutableMetadata

@dynamic sessionId;

- (void)setIntegration:(BTClientMetadataIntegrationType)integration {
    _integration = integration;
}

- (void)setSource:(BTClientMetadataSourceType)source {
    _source = source;
}

- (void)setSessionId:(NSString *)sessionId {
    _sessionId = sessionId;
}

@end
