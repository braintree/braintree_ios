import UIKit

public protocol ClientAuthorization {
    
    var type: AuthorizationType { get }
    var configURL: URL { get }
    var bearer: String { get }
    
    /// The original Client token or Tokenization Key string
    var originalValue: String { get } // TODO: rawValue re-name
}

public enum AuthorizationType {
    case tokenizationKey
    case clientToken
}
