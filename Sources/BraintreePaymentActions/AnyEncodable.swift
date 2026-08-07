import Foundation

/// A type-erased `Encodable` wrapper used to encode a payment method-specific payload without `BTPaymentActionsClient` needing to know its concrete type.
struct AnyEncodable: Encodable {
    
    private let value: any Encodable
    
    init(_ value: any Encodable) {
        self.value = value
    }
    
    func encode(to encoder: any Encoder) throws {
        try value.encode(to: encoder)
    }
}

