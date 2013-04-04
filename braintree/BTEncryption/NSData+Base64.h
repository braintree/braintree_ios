//
//  BASE64 Encoding/Decoding
//  Copyright (c) 2001 Kyle Hammond. All rights reserved.
//  Original development by Dave Winer.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

+ (NSData *) dataWithBase64EncodedString:(NSString *)string;

- (id) initWithBase64EncodedString:(NSString *)string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger)lineLength;



@end
