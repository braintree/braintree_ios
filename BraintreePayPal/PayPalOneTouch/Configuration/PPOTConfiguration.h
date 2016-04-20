//
//  PPOTConfiguration.h
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPOTCore.h"
#import "PPOTRequest.h"

@interface PPOTConfigurationRecipe : NSObject <NSCoding>
@property (nonatomic, assign, readwrite) PPOTRequestTarget target;
@property (nonatomic, strong, readwrite) NSNumber     *protocolVersion;
@property (nonatomic, copy, readwrite)   NSArray      *supportedLocales;  // these have been uppercased, to prevent capitalization mistakes
@property (nonatomic, copy, readwrite)   NSString     *targetAppURLScheme;
@property (nonatomic, copy, readwrite)   NSArray      *targetAppBundleIDs;
@property (nonatomic, copy, readwrite)   NSDictionary *environments;
@end

@interface PPOTConfigurationRecipeEndpoint : NSObject <NSCoding>
@property (nonatomic, copy, readwrite) NSString *url;
@property (nonatomic, copy, readwrite) NSString *certificateSerialNumber;
@property (nonatomic, copy, readwrite) NSString *base64EncodedCertificate;
@end

@interface PPOTConfigurationOAuthRecipe : PPOTConfigurationRecipe <NSCoding>
@property (nonatomic, copy, readwrite) NSSet *scope;
@property (nonatomic, copy, readwrite) NSDictionary *endpoints; // dictionary of PPOTConfigurationRecipeEndpoint
@end

@interface PPOTConfigurationCheckoutRecipe : PPOTConfigurationRecipe <NSCoding>
// no subclass-specific properties, so far
@end

@interface PPOTConfigurationBillingAgreementRecipe : PPOTConfigurationRecipe <NSCoding>
// no subclass-specific properties, so far
@end

@class PPOTConfiguration;

typedef void (^PPOTConfigurationCompletionBlock)(PPOTConfiguration *currentConfiguration);

@interface PPOTConfiguration : NSObject <NSCoding>

/// In the background: if the cached configuration is stale, then downloads the latest version.
+ (void)updateCacheAsNecessary;

/// Returns the current configuration, either from cache or else the hardcoded default configuration.
+ (PPOTConfiguration *)getCurrentConfiguration;

/// This method is here only for PPOTConfigurationTest.
/// Everyone else, please stick to using [PPOTConfiguration getCurrentConfiguration]!!!
+ (PPOTConfiguration *)configurationWithDictionary:(NSDictionary *)dictionary;

#if DEBUG
+ (void)useHardcodedConfiguration:(BOOL)useHardcodedConfiguration;
#endif

@property (nonatomic, copy, readwrite) NSString *fileTimestamp;
@property (nonatomic, copy, readwrite) NSArray  *prioritizedOAuthRecipes;
@property (nonatomic, copy, readwrite) NSArray  *prioritizedCheckoutRecipes;
@property (nonatomic, copy, readwrite) NSArray  *prioritizedBillingAgreementRecipes;

@end

// The following definitions are for backwards compatibility
@interface PPConfiguration: PPOTConfiguration
@end

@interface PPConfigurationCheckoutRecipe : PPOTConfigurationCheckoutRecipe
@end

@interface PPConfigurationBillingAgreementRecipe : PPOTConfigurationBillingAgreementRecipe
@end

@interface PPConfigurationOAuthRecipe : PPOTConfigurationOAuthRecipe
@end

@interface PPConfigurationRecipeEndpoint : PPOTConfigurationRecipeEndpoint
@end




