import Foundation

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
/// A helper class for converting URL queries to and from dictionaries
@_documentation(visibility: private)
@objc public class BTURLUtils: NSObject {

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Converts a key/value dictionary to a valid query string
    /// - Parameters:
    ///  - dict: Dictionary of key/value pairs to be encoded into a query string
    /// - Returns: A URL encoded query string
    public static func queryString(from dict: NSDictionary) -> String {
        var queryString: String = ""
        for (rawKey, value) in dict {
            guard let key = rawKey as? String else {
                continue
            }

            let encodedKey = encode(key.description)
            
            if let arrayValue = value as? [String] {
                for item in arrayValue {
                    queryString = queryString.appendingFormat("%@%%5B%%5D=%@&", encodedKey, encode(item.description))
                }
            } else if let dictValue = value as? [String: String] {
                for (subKey, subValue) in dictValue {
                    queryString = queryString.appendingFormat(
                        "%@%%5B%@%%5D=%@&",
                        encodedKey,
                        encode(subKey.description),
                        encode(subValue.description)
                    )
                }
            } else if value is NSNull {
                queryString = queryString.appendingFormat("%@=&", encodedKey)
            } else {
                queryString = queryString.appendingFormat("%@=%@&", encodedKey, encode(String(describing: value).description))
            }
        }
        
        return String(queryString.dropLast())
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Extract query parameters from a URL
    /// - Parameters:
    ///   - url: URL to parse query parameters from
    /// - Returns: Query parameters from the URL in a key/value dictionary
    public static func queryParameters(for url: URL) -> [String: String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var parameters: [String: String] = [:]
        
        guard let queryItems = components?.queryItems else {
            return parameters
        }

        for queryItem in queryItems {
            parameters[queryItem.name] = queryItem.value?.replacingOccurrences(of: "+", with: " ")
        }
        
        return parameters
    }
    
    private static func encode(_ string: String) -> String {
        // See Section 2.2. http://www.ietf.org/rfc/rfc2396.txt
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove(charactersIn: ";/?:@&=+$,")
        return string.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
    }
}
