import Foundation

/// An `Encodable` type containing POST body details & additional metadata params formatted for the BT Gateway & BT GraphQL API
struct BTAPIRequest: Encodable {
    
    private let requestBody: Encodable
    private let metadata: BTClientMetadata
    private let httpType: BTAPIClientHTTPService
    
    private enum MetadataKeys: String, CodingKey {
        case gatewayMetadataKey = "_meta"
        case graphQLMetadataKey = "clientSdkMetadata"
    }
    
    init(requestBody: Encodable, metadata: BTClientMetadata, httpType: BTAPIClientHTTPService) {
        self.requestBody = requestBody
        self.metadata = metadata
        self.httpType = httpType
    }

    func encode(to encoder: Encoder) throws {
        try requestBody.encode(to: encoder)
        
        // https://stackoverflow.com/questions/50461744/swift-codable-how-to-encode-top-level-data-into-nested-container
        var metadataContainer = encoder.container(keyedBy: MetadataKeys.self)
        if httpType == .gateway {
            let metadataEncoder = metadataContainer.superEncoder(forKey: .gatewayMetadataKey)
            try self.metadata.encode(to: metadataEncoder)
        } else if httpType == .graphQLAPI {
            let metadataEncoder = metadataContainer.superEncoder(forKey: .graphQLMetadataKey)
            try self.metadata.encode(to: metadataEncoder)
        }
    }
}
