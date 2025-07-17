import Foundation

public struct BTPayPalPhoneNumber: Encodable {
    
    private let countryCode: String
    private let nationalNumber: String
    
    private enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case nationalNumber = "national_number"
    }
    
    /// Intialize a `BTPayPalPhoneNumber`
    /// - Parameters:
    ///    - countryCode: The international country code for the shopper's phone number i.e. "1" for US
    ///    - nationalNumber: The national segment of the shopper's phone number
    public init(countryCode: String, nationalNumber: String) {
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if !countryCode.isEmpty && !nationalNumber.isEmpty {
            try container.encode(countryCode, forKey: .countryCode)
            try container.encode(nationalNumber, forKey: .nationalNumber)
        }
    }
}
