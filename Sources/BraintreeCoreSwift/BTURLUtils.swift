import Foundation

@objc public class BTURLUtils: NSObject {
  
    @objc(queryStringWithDictionary:)
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
                    queryString = queryString.appendingFormat("%@%%5B%@%%5D=%@&", encodedKey, encode(subKey.description), encode(subValue.description))
                }
            } else if let _ = value as? NSNull {
                queryString = queryString.appendingFormat("%@=&", encodedKey)
            } else {
                queryString = queryString.appendingFormat("%@=%@&", encodedKey, encode(String(describing: value).description))
            }
        }
        
        return String(queryString.dropLast())
    }
    
    @objc(queryParametersForURL:)
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
    
    static func encode(_ string: String) -> String {
        // See Section 2.2. http://www.ietf.org/rfc/rfc2396.txt
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove(charactersIn: ";/?:@&=+$,")
        return string.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
    }
}
