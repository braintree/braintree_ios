import Foundation

// TODO: - To be removed once entire SDK is formatting POST bodies using Encodable
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
                throw BTHTTPError.serializationError("Serialization to dictionary failed.")
            }
        } catch let error {
            throw BTHTTPError.serializationError(error.localizedDescription)
        }
    }
}
