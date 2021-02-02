#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTClientMetadata.h>
#else
#import <BraintreeCore/BTClientMetadata.h>
#endif

@interface BTClientMetadata () {
    @protected
    BTClientMetadataIntegrationType _integration;
    BTClientMetadataSourceType _source;
    NSString *_sessionID;
}
@end

@implementation BTClientMetadata

- (instancetype)init {
    self = [super init];
    if (self) {
        _integration = BTClientMetadataIntegrationCustom;
        _source = BTClientMetadataSourceUnknown;
        _sessionID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BTClientMetadata *copiedMetadata = [[BTClientMetadata allocWithZone:zone] init];
    copiedMetadata->_integration = _integration;
    copiedMetadata->_source = _source;
    copiedMetadata->_sessionID = [_sessionID copyWithZone:zone];
    return copiedMetadata;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    BTMutableClientMetadata *mutableMetadata = [[BTMutableClientMetadata allocWithZone:zone] init];
    mutableMetadata.integration = _integration;
    mutableMetadata.source = _source;
    mutableMetadata.sessionID = [_sessionID copyWithZone:zone];
    return mutableMetadata;
}

- (NSString *)integrationString {
    return [[self class] integrationToString:self.integration];
}

- (NSString *)sourceString {
    return [[self class] sourceToString:self.source];
}

- (NSDictionary *)parameters {
    return @{
             @"integration": self.integrationString,
             @"source": self.sourceString,
             @"sessionId": self.sessionID
             };
}

#pragma mark Internal helpers

+ (NSString *)integrationToString:(BTClientMetadataIntegrationType)integration {
    switch (integration) {
        case BTClientMetadataIntegrationCustom:
            return @"custom";
        case BTClientMetadataIntegrationDropIn:
            return @"dropin";
        case BTClientMetadataIntegrationDropIn2:
            return @"dropin2";
        case BTClientMetadataIntegrationUnknown:
            return @"unknown";
    }
}

+ (NSString *)sourceToString:(BTClientMetadataSourceType)source {
    switch (source) {
        case BTClientMetadataSourcePayPalApp:
            return @"paypal-app";
        case BTClientMetadataSourcePayPalBrowser:
            return @"paypal-browser";
        case BTClientMetadataSourceVenmoApp:
            return @"venmo-app";
        case BTClientMetadataSourceForm:
            return @"form";
        case BTClientMetadataSourceUnknown:
            return @"unknown";
    }
}

@end


@implementation BTMutableClientMetadata

- (void)setIntegration:(BTClientMetadataIntegrationType)integration {
    _integration = integration;
}

- (void)setSource:(BTClientMetadataSourceType)source {
    _source = source;
}

- (void)setSessionID:(NSString *)sessionID {
    _sessionID = sessionID;
}

@end
