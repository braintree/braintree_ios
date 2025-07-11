/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>

/// Closure/block used to respond to a Visa Checkout request for data.
typedef void(^VisaConfigResponse)(id _Nonnull data);
/// :nodoc:
typedef void(^VisaConfigRequest)(id _Nullable info, VisaConfigResponse _Nonnull sendResponse);

/// :nodoc:
@interface VInitInfo : NSObject

- (instancetype _Nonnull)init;
- (id _Nullable)objectForKeyedSubscript:(NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)obj forKeyedSubscript:(NSString * _Nonnull)key;

@end
