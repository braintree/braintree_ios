//
//  ConfigParameters.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The ConfigParameters class represent the configuration parameters that are required by the 3DS SDK for initialization.
 */
@interface ConfigParameters : NSObject

/**
 * The addParam method adds a configuration parameter either to the specified group.
 * @param group Group to which the configuration parameter is to be added.
 * @param paramName Name of the configuration parameter.
 * @param paramValue Value of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) addParamToGroup: (NSString *) group
           withParamName: (nonnull NSString*) paramName
              paramValue: (NSString*) paramValue
                   error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(addParam(_:name:value:));

/**
 * The addParam method adds a configuration parameter either to the specified group.
 * @param group Group to which the configuration parameter is to be added.
 * @param paramName Name of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) addParamToGroup: (NSString *) group
           withParamName: (nonnull NSString*) paramName
                   error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(addParam(_:name:));

/**
 * The addParam method adds a configuration parameter either to the default group.
 * @param paramName Name of the configuration parameter.
 * @param paramValue Value of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) addParamWithParamName: (nonnull NSString*) paramName
                    paramValue: (nonnull NSString*) paramValue
                         error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(addParam(_:value:));

/**
 * The addParam method adds a configuration parameter either to the default group.
 * @param paramName Name of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) addParamWithParamName: (nonnull NSString*) paramName
                         error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(addParam(_:));


/**
 * The getParamValue method returns a configuration parameter’s value either from the specified group.
 * @param group Group to which the configuration parameter is added.
 * @param paramName Name of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 * @return NSString
 */
- (nullable NSString *) getParamValueFromGroup: (NSString*) group
                                 withParamName: (nonnull NSString*) paramName
                                         error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(getParam(_:name:));

/**
 * The getParamValue method returns a configuration parameter’s value either from default group.
 * @param paramName Name of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 * @return NSString
 */
- (nullable NSString *) getParamValueWithParamName: (nonnull NSString*) paramName
                                             error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(getParam(_:));

/**
 * The removeParam method returns the name of the parameter that it removed.
 * @param group Group to which the configuration parameter is added.
 * @param paramName Name of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 * @return NSString
 */
- (nullable NSString *) removeParamFromGroup: (NSString*) group
                               withParamName: (nonnull NSString*) paramName
                                       error: (NSError **)error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(removeParam(_:name:));

/**
 * The removeParam method returns the name of the parameter that it removed.
 * @param paramName Name of the configuration parameter.
 * @param error Reference to NSError Object to handle exceptions.
 * @return NSString
 */
- (nullable NSString *) removeParamWithParamName: (nonnull NSString*) paramName
                                           error: (NSError **)error __attribute__((swift_error(nonnull_error)))  NS_SWIFT_NAME(removeParam(_:));

@end
