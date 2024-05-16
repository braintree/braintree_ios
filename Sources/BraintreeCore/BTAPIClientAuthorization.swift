import UIKit

public enum BTAPIClientAuthorization {
    case tokenizationKey
    case clientToken
}

public protocol Authorization {
    
    var type: BTAPIClientAuthorization { get }
    var configURL: URL { get }
    var bearer: String { get }
    
    /// The original Client token or Tokenization Key string
    var originalValue: String { get } // TODO: rawValue re-name
}
