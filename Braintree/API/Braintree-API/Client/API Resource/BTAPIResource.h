@import Foundation;

#import "BTAPIResourceErrors.h"

/// A BTAPIResource subclass models a bidirectional mapping between API responses and native model objects.
///
/// This class provides two sets of the methods. Mapping: modelWithAPIDictionary:error: and
/// APIDictionaryWithModel: *perform translations* between the model and
/// API Dictionary representations of an API Resource. Description: resourceModelClass and APIFormat
/// are abstract methods that subclasses must override in order to *describe* the shape of the API
/// resource.
///
/// ## API Format
///
/// There are a number of rules and assumptions that govern API Dictionary parsing:
/// * API Dictionaries must include values for all non-optional keys
/// * API Dictionaries may include extraeous keys
/// * The type and interpretation of API Dictionary values is determined by ValueTypes in the API Format
///
/// ## ValueTypes
///
/// Value types describe each value in the API Dictionary. They do not actually parse the values;
/// rather you should think of them as functional descriptions of an API value. ValueTypes
/// specify several things about each API Dictionary key-value pair:
/// * semantics (e.g. optional?)
/// * format parsing (e.g. 1/0 -> BOOL),
/// * value capture (e.g. save value in model via a @selector or block)
///
/// ValueTypes are implemented as objects that conform to BTAPIResourceValueType.
///
/// Note: Only a small number of ValueTypes are currently implemented. Depending on API needs, we
///       should implement more of them.
@interface BTAPIResource : NSObject

/// Creates and returns a new model object based on an API dictionary.
///
/// @param APIDictionary A dictionary representation of the API resource, usually constructed by parsing the API transport (e.g. JSON)
/// @param error         An error pointer for passing errors by reference when there is a problem parsing the APIDictionary or creating the model.
///
/// @see BTAPIResourceErrors.h
///
/// @return A new model object to represent the API resource
+ (id)modelWithAPIDictionary:(NSDictionary *)APIDictionary error:(NSError *__autoreleasing *)error;

/// Creates and returns an API Dictionary based on the given model object.
///
/// @param resource A model object covariant with resourceModelClass
///
/// @return A dictionary represnetation of the API resource, ready to be sent to the API (e.g. as JSON or Form Encoded)
+ (NSDictionary *)APIDictionaryWithModel:(id)resource;


#pragma mark Abstract Methods

/// Returns the class type of this API Resource's native model representation.
///
/// Subclasses *must* override this method.
///
/// @return A model class
+ (Class)resourceModelClass;

/// Returns the API Format for this API Resource.
///
/// * An API Format is an NSDictionary that _describes_ the shape of the API resource.
/// * The keys of this dictionary must be strings.
/// * The keys must match the keys of the API Dictionary keys exactly.
/// * The values must conform to BTAPIResourceValueType
///
/// Here is an example APIFormat:
///
/// ```
///  @{ @"api-key-with-string-value": BTAPIResourceValueTypeString(@selector(setString:)),
///     @"api-key-with-string-set-value": BTAPIResourceValueTypeStringSet(@selector(setStringSet:)),
///     @"api-key-with-optional-string-value": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeString(@selector(setOptionalString:))) }
/// ```
///
/// @see BTAPIResourceValueTypeString
///
/// @return An APIFormat
+ (NSDictionary *)APIFormat;

@end


#pragma mark Value Types for use in APIFormat

@protocol BTAPIResourceValueType;

/// A ValueType that parses a string and saves it in the model with a selector.
///
/// @param setter A selector that is sent to the model object with the value as the first argument
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeString(SEL setter);

/// A ValueType that parses a BOOL and saves it in the model with a selector.
///
/// @param setter A selector that is sent to the model object with the BOOL value as the first argument
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeBool(SEL setter);

/// A ValueType that parses a set of strings and saves it in the model as an NSSet with a selector.
///
/// Note: This value type will accept an array or a set; the cannonical represnetation is a NSSet.
///
/// @param setter A selector that is sent to the model object with the value as the first argument
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeStringSet(SEL setter);

/// A ValueType that parses an array of strings and saves it in the model as an NSArray with a selector.
///
/// @param setter A selector that is sent to the model object with the value as the first argument
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeStringArray(SEL setter);

/// A ValueType that parses a nested API resource and saves it in the model with a selector.
///
/// @param setter A selector that is sent to the model object with the nested model as the first argument
/// @param BTAPIResourceClass The BTAPIResource that models the nested resource
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeAPIResource(SEL setter, Class BTAPIResourceClass);

/// A ValueType that wraps another ValueType, in order to map the API values to native values.
///
/// Note: The *mapped* value will be passed to the selector of the ValueType this function receives.
///
/// @param APIResourceValueType Another ValueType that describes the value if it is present
/// @param map a Dictionary that maps API values to native value
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeMap(id<BTAPIResourceValueType> APIResourceValueType, NSDictionary *map);

/// A ValueType that wraps another ValueType, making it optional in the API
///
/// @param APIResourceValueType Another ValueType that describes the value if it is present
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeOptional(id<BTAPIResourceValueType> APIResourceValueType);

/// A ValueType that maps API strings to enum values
///
/// Example API mapping: `@{ @"on": @YES, @"off": @NO }` for API Dictionary: `@{ @"doCrazyThing": @"on" }`
///
/// @param setter A selector that is sent to the model object with the enum value as the first argument
/// @param mapping A mapping from string values present in the API to enum values
///
/// @return A ValueType for use in `APIFormat`s
id<BTAPIResourceValueType> BTAPIResourceValueTypeEnumMapping(SEL setter, NSDictionary *mapping);
