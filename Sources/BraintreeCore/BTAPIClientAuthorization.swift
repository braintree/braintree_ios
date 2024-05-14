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

//extension Authorization {
//
//    func isTokenizationKey() {
//        print("Drawing a \(bearer) shape.")
//    }
//}

class BTTokenizationKey: Authorization {
    
    let type = BTAPIClientAuthorization.tokenizationKey
    
    let bearer: String
    let configURL: URL
    let originalValue: String
    
    init(_ rawValue: String) {
        self.bearer = rawValue
        self.configURL = URL(string: "www.apple.com")!
        self.originalValue = rawValue
    }
}
