import UIKit
import XCTest
@testable import BraintreeCore

final class Encodable_Dictionary_Tests: XCTestCase {
    
    let fakeEncodable = FakeEncodable(fake: "value")
    
    func testToDictionary_whenEncodingSucceeds_returnsDictionary() {
        do {
            let jsonDictionary = try fakeEncodable.toDictionary()
            XCTAssertEqual(jsonDictionary["fake"] as? String, "value")
        } catch {
            XCTFail("Expected json serialization to succeed.")
        }
    }
    
    func testToDictionary_whenEncodingFails_throwsError() {
        do {
            _ = try fakeEncodable.toDictionary(MockJSONEncoder())
        } catch let error {
            let error = error as NSError
            XCTAssertEqual(error.domain, "com.braintreepayments.BTHTTPErrorDomain")
            XCTAssertEqual(error.code, BTHTTPError.serializationError("").errorCode)
        }
    }
    
    struct FakeEncodable: Encodable {
        let fake: String
    }
}

class MockJSONEncoder: JSONEncoder {
    
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        throw EncodingError.invalidValue(1, EncodingError.Context(codingPath: [], debugDescription: ""))
    }
}
