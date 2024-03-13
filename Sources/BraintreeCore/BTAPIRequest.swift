import Foundation

/// An `Encodable` type containing POST body details & metadata params formatted for the BT Gateway & BT GraphQL API
struct BTAPIRequest: Encodable {
    
    private let requestBody: Encodable
    private let metadata: BTClientMetadata
    private let httpType: BTAPIClientHTTPService
    
    private enum MetadataKeys: String, CodingKey {
        case gatewayMetadataKey = "_meta"
        case graphQLMetadataKey = "clientSdkMetadata"
    }
    
    /// Initialize a `BTAPIRequest` to format a POST body with metadata params for BT APIs.
    /// - Parameters:
    ///   - requestBody: The actual POST body details.
    ///   - metadata: The metadata details to append into the POST body.
    ///   - httpType: The Braintree API type for this request.
    init(requestBody: Encodable, metadata: BTClientMetadata, httpType: BTAPIClientHTTPService) {
        self.requestBody = requestBody
        self.metadata = metadata
        self.httpType = httpType
    }

    func encode(to encoder: Encoder) throws {
        try requestBody.encode(to: encoder)
        
        var metadataContainer = encoder.container(keyedBy: MetadataKeys.self)
        switch httpType {
        case .gateway:
            let metadataEncoder = metadataContainer.superEncoder(forKey: .gatewayMetadataKey)
            try self.metadata.encode(to: metadataEncoder)
        case .graphQLAPI:
            let metadataEncoder = metadataContainer.superEncoder(forKey: .graphQLMetadataKey)
            try self.metadata.encode(to: metadataEncoder)
        case .payPalAPI:
            break
        }
    }
}
