import Foundation

public extension Encodable {

    /// Converts to dictionary `[String: Any]` type.
    ///
    /// Used to satisfy limitations of current BTHTTP implementation.
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        do {
            let data = try encoder.encode(self)
            let object = try JSONSerialization.jsonObject(with: data)

            if let json = object as? [String: Any] {
                return json
            } else {
                throw NSError(
                    domain: "EncodableConversionError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Serialization to dictionary failed"]
                )
            }
        } catch let error {
            throw error
        }
    }
}
