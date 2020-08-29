class BTPayPalIDTokenTestHelper: NSObject {
    
    @objc static func encodeIDToken(_ dict: [String : Any]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return "123.\(data.base64EncodedString()).456"
    }
}
