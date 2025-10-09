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
    
    struct FakeEncodable: Encodable {
        let fake: String
    }
}
