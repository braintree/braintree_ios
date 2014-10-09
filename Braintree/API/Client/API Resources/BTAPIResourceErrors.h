@import Foundation;

/// An error domain for BTAPIResource errors
extern NSString *const BTAPIResourceErrorDomain;

/// Error codes for BTAPIResourceErrorDomain errors
typedef NS_ENUM(NSInteger, BTAPIResourceErrorCode) {
    /// An unknown error occured
    BTAPIResourceErrorUnknown,
    /// The APIFormat is invalid
    BTAPIResourceErrorAPIFormatInvalid,
    /// The API Dictionary is missing a non-optional key
    BTAPIResourceErrorAPIDictionaryMissingKey,
    /// The API Dictionary contains an invalid entity
    BTAPIResourceErrorAPIDictionaryInvalid,
    /// The API Dictionary contains an invalid nested resource
    BTAPIResourceErrorAPIDictionaryNestedResourceInvalid,
};