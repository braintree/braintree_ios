//
//  CardinalError.h
//  CardinalMobile
//
//  Created by Praveen Rao on 8/31/22.
//  Copyright © 2022 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardinalError : NSObject

@property (nonatomic, strong, readonly) NSString* errorCode;
@property (nonatomic, strong, readonly) NSString* errorDescription;

/**
 * Construct an CardinalError object.
 * @param errorCode Error Code.
 * @param errorDescription Description of Error.
 * @return ErrorMessage
 */
- (id) initWithErrorCode: (NSString*) errorCode
        errorDescription: (NSString *) errorDescription;

/**
 * The getErrorCode method returns the error code.
 * @return NSInteger
 */
- (NSString*) getErrorCode;

/**
 * The getErrorDescription method returns text describing the error.
 * @return NSString
 */
- (NSString *) getErrorDescription;

@end

NS_ASSUME_NONNULL_END
