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
    ///    - countryCode: The international country code for the shopper's phone number
    ///    (must be 1 to 3 digits, no symbols or spaces allowed; e.g., "1" for the United States).
    ///    - nationalNumber: The national segment of the shopper's phone number
    ///    (must be 4 to 12 digits, no symbols or spaces allowed; excludes the country code).
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
