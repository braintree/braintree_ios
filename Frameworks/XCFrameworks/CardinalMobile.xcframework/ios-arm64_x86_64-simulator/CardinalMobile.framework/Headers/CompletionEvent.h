//
//  CompletionEvent.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * The CompletionEvent class holds data about completion of the challenge process.
 */
@interface CompletionEvent : NSObject

- (id _Nonnull ) initWithSDKTransactionID: (nonnull NSString *) sdkTransactionID
                        transactionStatus: (nonnull NSString *) transactionStatus;

@property (nonatomic, strong, nonnull, readonly) NSString* sdkTransactionID;
@property (nonatomic, strong, nonnull, readonly) NSString* transactionStatus;

/**
 * Returns the SDK Transaction ID.
 * @return NSString
 */
- (nonnull NSString *) getSDKTransactionID;

/**
 * Returns the transaction status that was received in the final CRes.
 * @return NSString
 */
- (nonnull NSString *) getTransactionStatus;

+ (instancetype _Nonnull )new NS_UNAVAILABLE;
- (instancetype _Nonnull )init NS_UNAVAILABLE;

@end
