import Foundation

@objc public class BTURLUtils: NSObject {
  
    @objc(queryStringWithDictionary:)
    public static func queryString(from dict: NSDictionary) -> String {
        var queryString: String = ""
        for (rawKey, value) in dict {
            guard let key = rawKey as? String else {
                continue
            }
            let encodedKey = encode(key)
            
            if let arrayValue = value as? [String] {
                for item in arrayValue {
                    queryString.append("\(encodedKey)%%5B%%5D=\(encode(item))&")
                }
            } else if let dictValue = value as? [String: String] {
                for (subkey, subvalue) in dictValue {
                    queryString.append("\(encodedKey)%%5B\(encode(subkey))%%5D=\(encode(subvalue))&")
                }
            } else if let _ = value as? NSNull {
                queryString.append("\(encodedKey)=&")
            } else {
                queryString.append("\(encodedKey)=\(encode(String(describing: value)))&")
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
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
