import Foundation

/// Marker protocol refining `BTGraphQLEncodableBody` for Payment Actions mutations.
/// Each payment method's request body (i.e. `CardSetPaymentMethodGraphQLBody`) conforms to this.
public protocol BTPaymentActionsGraphQLBody: BTGraphQLEncodableBody { }
