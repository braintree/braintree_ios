//
//  Warning.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The Severity enum defines the severity levels of warnings produced by the 3DS SDK while conducting security checks during initialization.
 */
typedef enum{
    /**SeverityLow A low-severity warning.*/
    SeverityLow,
    
    /**SeverityMedium A medium-severity warning.*/
    SeverityMedium,
    
    /**SeverityHigh A high-severity warning.*/
    SeverityHigh
}Severity;

/**
 * The Warning class represents a warning that is produced by the 3DS SDK while performing security checks during initialization.
 */
@interface Warning : NSObject

/**
 * @property warningId Warning ID.
 */
@property (nonatomic, strong) NSString* warningID;

/**
 * @property message Warning message.
 */
@property (nonatomic, strong) NSString* message;

/**
 * @property severity Warning severity level.
 */
@property (nonatomic, assign) Severity severity;

@end
