#import "BTPayPalDriver3.h"

#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

#import "BTTokenizedPayPalAccount_Internal.h"
#import "BTLogger_Internal.h"
#import "BTAPIClient_Internal.h"
#import "BTPostalAddress_Internal.h"
#import "BTClientMetadata.h"


#import "BTAppSwitch.h"

//
// TODO: Add this file back to the Braintree target and fix it and test it and stuff
//

NSString *const BTPayPalDriver3ErrorDomain = @"com.braintreepayments.BTPayPalDriver3ErrorDomain";

@interface BTPayPalDriver3 ()
@property (nonatomic, strong) BTAPIClient *configuration;
@property (nonatomic, strong) BTAPIClient *client;
@property (nonatomic, copy) NSString *returnURLScheme;
@end

@implementation BTPayPalDriver3

- (instancetype)initWithAPIClient:(BTAPIClient * __nonnull)configuration {
    NSError *initializationError;
    if (![BTPayPalDriver3 verifyAppSwitchConfiguration:configuration
                                       returnURLScheme:configuration.returnURLScheme
                                                 error:&initializationError]) {
        [[BTLogger sharedLogger] log:@"Failed to initialize BTPayPalDriver3: %@", initializationError];
        return nil;
    }

    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.client = [[BTAPIClient alloc] initWithBaseURL:configuration.baseURL authorizationFingerprint:configuration.clientKey];
        self.returnURLScheme = configuration.returnURLScheme;
    }
    return self;
}

#pragma mark - PayPal Lifecycle




#pragma mark -



@end
