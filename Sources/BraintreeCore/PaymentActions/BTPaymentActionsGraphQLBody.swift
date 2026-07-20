import Foundation

/// Marker protocol refining `BTGraphQLEncodablebody` for Payment Actions mutations.
/// Each payment method's request body (i.e. `CardSetPaymentMethodGraphQLBody`) conforms to this.
public protocol BTPaymentActionsGraphQLBody: BTGraphQLEncodableBody { }
