#import <Foundation/Foundation.h>

@interface BTUIKCardExpiryFormat : NSObject
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) NSUInteger cursorLocation;
@property (nonatomic, assign) BOOL backspace;

- (void)formattedValue:(NSString * __autoreleasing *)value cursorLocation:(NSUInteger *)cursorLocation;

@end
