import Foundation

@objc public class BTURLUtilsSwift: NSObject {
  
    @objc public static func queryStringWithDictionary(dict: NSDictionary) -> String {
        return ""
    }
    
    @objc public static func queryParametersForURL(url: URL) -> [String: String] {
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
    
    
    
    func stringByURLEncodingAllCharactersInString(string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
