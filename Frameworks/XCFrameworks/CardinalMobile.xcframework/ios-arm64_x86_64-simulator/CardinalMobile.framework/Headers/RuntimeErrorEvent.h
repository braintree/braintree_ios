//
//  RuntimeErrorEvent.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The RuntimeErrorEvent class holds details of run-time errors that are encountered by the 3DS SDK during authentication.
 */
@interface RuntimeErrorEvent : NSObject

@property (nonatomic, strong, nonnull, readonly) NSString* errorCode;
@property (nonatomic, strong, nonnull, readonly) NSString* errorMessage;

- (id _Nonnull ) initWithErrorCode: (nonnull NSString *) errorCode
                      errorMessage: (nonnull NSString *) errorMessage;

/**
 * Returns the implementer-specific error code.
 * @return NSString
 */
- (nonnull NSString *) getErrorCode;

/**
 * Returns details about the error.
 * @return NSString
 */
- (nonnull NSString *) getErrorMessage;

+ (instancetype _Nonnull )new NS_UNAVAILABLE;
- (instancetype _Nonnull )init NS_UNAVAILABLE;

@end
