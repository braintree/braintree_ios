#import <Foundation/Foundation.h>
#import "BTClientCardTokenizationRequest.h"

/// Representation of a card that should be uploaded to Braintree for payment method creation.
///
/// @see BTClientCardTokenizationRequest
@interface BTClientCardRequest : BTClientCardTokenizationRequest

/// Whether or not to return validations and/or verification results to the client
///
/// @warning Use this flag with caution. By enabling client-side validation, certain save card requests
///          may result in adding the payment method to the Vault. These semantics are not currently
///          documented.
@property (nonatomic, readwrite, assign) BOOL shouldValidate;

/// Initializes a request with an empty set of card details
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// Initializes a request based on card details in a BTClientCardTokenizationRequest
- (instancetype)initWithTokenizationRequest:(BTClientCardTokenizationRequest *)tokenizationRequest;

@end
