import XCTest
@testable import BraintreeCore

final class MockApplicationStateProvider: ApplicationStateProviding {
    
    let applicationState: UIApplication.State
    
    init(applicationState: UIApplication.State) {
        self.applicationState = applicationState
    }
}
    
class UIApplicationApplicationStateTests: XCTestCase {
    
    func testApplicationStateString_Active() {
        let mockProvider = MockApplicationStateProvider(applicationState: .active)
        XCTAssertEqual(mockProvider.applicationState.asString, "active")
    }
    
    func testApplicationStateString_Inactive() {
        let mockProvider = MockApplicationStateProvider(applicationState: .inactive)
        XCTAssertEqual(mockProvider.applicationState.asString, "inactive")
    }
    
    func testApplicationStateString_Background() {
        let mockProvider = MockApplicationStateProvider(applicationState: .background)
        XCTAssertEqual(mockProvider.applicationState.asString, "background")
    }
    
    func testApplicationStateString_Unknown() {
        let mockProvider = MockApplicationStateProvider(applicationState: UIApplication.State(rawValue: 999)!)
        XCTAssertEqual(mockProvider.applicationState.asString, "unknown")
    }
}
