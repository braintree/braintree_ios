import XCTest

class BTAppContextSwitcher_Tests: XCTestCase {
    var appSwitch = BTAppContextSwitcher.sharedInstance()

    override func setUp() {
        super.setUp()
        appSwitch = BTAppContextSwitcher.sharedInstance()
    }

    override func tearDown() {
        MockAppContextSwitchDriver.cannedCanHandle = false
        MockAppContextSwitchDriver.lastCanHandleURL = nil
        MockAppContextSwitchDriver.lastHandleReturnURL = nil
        super.tearDown()
    }

    func testSetReturnURLScheme() {
        BTAppContextSwitcher.setReturnURLScheme("com.some.scheme")
        XCTAssertEqual(appSwitch.returnURLScheme, "com.some.scheme")
    }

    func testHandleOpenURLContext_whenDriverCanHandleOpenURL_invokesHandleReturnURL_andReturnsTrue() {
        appSwitch.register(MockAppContextSwitchDriver.self)
        MockAppContextSwitchDriver.cannedCanHandle = true

        let mockURLContext = BTMockOpenURLContext(url: URL(string: "my-url.com")!).mock

        let handled = BTAppContextSwitcher.handleOpenURLContext(mockURLContext)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchDriver.lastCanHandleURL, URL(string: "my-url.com"))
        XCTAssertEqual(MockAppContextSwitchDriver.lastHandleReturnURL, URL(string: "my-url.com"))
    }

    func testHandleOpenURLContext_whenDriverCantHandleOpenURL_doesNotInvokeHandleReturnURL_andReturnsFalse() {
        appSwitch.register(MockAppContextSwitchDriver.self)
        MockAppContextSwitchDriver.cannedCanHandle = false

        let mockURLContext = BTMockOpenURLContext(url: URL(string: "fake://url")!).mock

        let handled = BTAppContextSwitcher.handleOpenURLContext(mockURLContext)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchDriver.lastHandleReturnURL)
    }

    func testHandleOpenURLContext_withNoAppSwitching_returnsFalse() {
        let mockURLContext = BTMockOpenURLContext(url: URL(string: "fake://url")!).mock
        let handled = BTAppContextSwitcher.handleOpenURLContext(mockURLContext)
        XCTAssertFalse(handled)
    }

}

class MockAppContextSwitchDriver: BTAppContextSwitchDriver {
    static var cannedCanHandle = false
    static var lastCanHandleURL: URL?
    static var lastHandleReturnURL: URL?

    static func canHandleReturnURL(_ url: URL) -> Bool {
        lastCanHandleURL = url
        return cannedCanHandle
    }

    @objc static func handleReturnURL(_ url: URL) {
        lastHandleReturnURL = url
    }
}
