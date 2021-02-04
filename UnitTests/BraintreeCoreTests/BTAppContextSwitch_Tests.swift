import XCTest

class BTAppContextSwitch_Tests: XCTestCase {
    var appSwitch = BTAppContextSwitcher.sharedInstance()

    override func setUp() {
        super.setUp()
        appSwitch = BTAppContextSwitcher.sharedInstance()
    }

    override func tearDown() {
        MockAppContextSwitchHandler.cannedCanHandle = false
        MockAppContextSwitchHandler.lastCanHandleURL = nil
        MockAppContextSwitchHandler.lastHandleAppSwitchReturnURL = nil
        super.tearDown()
    }

    func testHandleOpenURL_whenHandlerIsRegistered_invokesCanHandleAppSwitchReturnURL() {
        appSwitch.register(MockAppContextSwitchHandler.self)
        let expectedURL = URL(string: "fake://url")!

        BTAppContextSwitcher.handleOpen(expectedURL)

        XCTAssertEqual(MockAppContextSwitchHandler.lastCanHandleURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCanHandleOpenURL_invokesHandleAppSwitchReturnURL_andReturnsTrue() {
        appSwitch.register(MockAppContextSwitchHandler.self)
        MockAppContextSwitchHandler.cannedCanHandle = true
        let expectedURL = URL(string: "fake://url")!

        let handled = BTAppContextSwitcher.handleOpen(expectedURL)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchHandler.lastHandleAppSwitchReturnURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCantHandleOpenURL_doesNotInvokeHandleAppSwitchReturnURL_andReturnsFalse() {
        appSwitch.register(MockAppContextSwitchHandler.self)
        MockAppContextSwitchHandler.cannedCanHandle = false

        let handled = BTAppContextSwitcher.handleOpen(URL(string: "fake://url")!)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchHandler.lastHandleAppSwitchReturnURL)
    }

    func testHandleOpenURLContext_whenHandlerCanHandleOpenURL_invokesHandleAppSwitchReturnURL_andReturnsTrue() {
        guard #available(iOS 13.0, *) else { return }

        appSwitch.register(MockAppContextSwitchHandler.self)
        MockAppContextSwitchHandler.cannedCanHandle = true

        let urlContext = MockOpenURLContext(url: URL(string: "my-url.com")!)

        let handled = BTAppContextSwitcher.handleOpenURLContext(urlContext)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchHandler.lastCanHandleURL, URL(string: "my-url.com"))
        XCTAssertEqual(MockAppContextSwitchHandler.lastHandleAppSwitchReturnURL, URL(string: "my-url.com"))
    }

    func testHandleOpenURLContext_whenHandlerCantHandleOpenURL_doesNotInvokeHandleAppSwitchReturnURL_andReturnsFalse() {
        guard #available(iOS 13.0, *) else { return }

        appSwitch.register(MockAppContextSwitchHandler.self)
        MockAppContextSwitchHandler.cannedCanHandle = false

        let urlContext = MockOpenURLContext(url: URL(string: "fake://url")!)

        let handled = BTAppContextSwitcher.handleOpenURLContext(urlContext)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchHandler.lastHandleAppSwitchReturnURL)
    }

    func testHandleOpenURL_withNoAppSwitching_returnsFalse() {
        let handled = BTAppContextSwitcher.handleOpen(URL(string: "scheme://")!)
        XCTAssertFalse(handled)
    }

}

class MockAppContextSwitchHandler: BTAppContextSwitchHandler {
    static var cannedCanHandle = false
    static var lastCanHandleURL : URL? = nil
    static var lastHandleAppSwitchReturnURL : URL? = nil

    static func canHandleAppSwitchReturn(_ url: URL) -> Bool {
        lastCanHandleURL = url
        return cannedCanHandle
    }

    @objc static func handleAppSwitchReturn(_ url: URL) {
        lastHandleAppSwitchReturnURL = url
    }
}

@available(iOS 13.0, *)
class MockOpenURLContext: UIOpenURLContext {

    private let _url: URL

    override var url: URL {
        return _url
    }

    init(url: URL) {
        self._url = url
    }
}
