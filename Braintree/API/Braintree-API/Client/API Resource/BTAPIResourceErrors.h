@import Foundation;

extern NSString *const BTAPIResourceErrorDomain;

typedef NS_ENUM(NSInteger, BTAPIResourceErrorCode) {
    BTAPIResourceErrorUnknown,
    BTAPIResourceErrorResourceSpecificationInvalid,
    BTAPIResourceErrorResourceDictionaryMissingKey,
    BTAPIResourceErrorResourceDictionaryInvalid,
    BTAPIResourceErrorResourceDictionaryNestedResourceInvalid,
};