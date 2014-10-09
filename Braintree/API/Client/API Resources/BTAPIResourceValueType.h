@import Foundation;

@protocol BTAPIResourceValueType

- (BOOL)isValidValue:(id)value;

- (BOOL)setValue:(id)value onModel:(id)model error:(NSError *__autoreleasing *)error;

- (NSError *)resourceValueTypeError;

@end
