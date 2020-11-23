import XCTest

class BTAppSwitch_Tests: XCTestCase {
    var appSwitch = BTAppSwitch.sharedInstance()

    override func setUp() {
        super.setUp()
        appSwitch = BTAppSwitch.sharedInstance()
    }

    override func tearDown() {
        MockAppSwitchHandler.cannedCanHandle = false
        MockAppSwitchHandler.lastCanHandleURL = nil
        MockAppSwitchHandler.lastHandleAppSwitchReturnURL = nil
        super.tearDown()
    }

    func testHandleOpenURL_whenHandlerIsRegistered_invokesCanHandleAppSwitchReturnURL() {
        appSwitch.register(MockAppSwitchHandler.self)
        let expectedURL = URL(string: "fake://url")!

        BTAppSwitch.handleOpen(expectedURL)

        XCTAssertEqual(MockAppSwitchHandler.lastCanHandleURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCanHandleOpenURL_invokesHandleAppSwitchReturnURL_andReturnsTrue() {
        appSwitch.register(MockAppSwitchHandler.self)
        MockAppSwitchHandler.cannedCanHandle = true
        let expectedURL = URL(string: "fake://url")!

        let handled = BTAppSwitch.handleOpen(expectedURL)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppSwitchHandler.lastHandleAppSwitchReturnURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCantHandleOpenURL_doesNotInvokeHandleAppSwitchReturnURL_andReturnsFalse() {
        appSwitch.register(MockAppSwitchHandler.self)
        MockAppSwitchHandler.cannedCanHandle = false

        let handled = BTAppSwitch.handleOpen(URL(string: "fake://url")!)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppSwitchHandler.lastHandleAppSwitchReturnURL)
    }

    func testHandleOpenURLContext_whenHandlerCanHandleOpenURL_invokesHandleAppSwitchReturnURL_andReturnsTrue() {
        guard #available(iOS 13.0, *) else { return }

        appSwitch.register(MockAppSwitchHandler.self)
        MockAppSwitchHandler.cannedCanHandle = true

        let urlContext = MockOpenURLContext(url: URL(string: "my-url.com")!)

        let handled = BTAppSwitch.handleOpenURLContext(urlContext)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppSwitchHandler.lastCanHandleURL, URL(string: "my-url.com"))
        XCTAssertEqual(MockAppSwitchHandler.lastHandleAppSwitchReturnURL, URL(string: "my-url.com"))
    }

    func testHandleOpenURLContext_whenHandlerCantHandleOpenURL_doesNotInvokeHandleAppSwitchReturnURL_andReturnsFalse() {
        guard #available(iOS 13.0, *) else { return }

        appSwitch.register(MockAppSwitchHandler.self)
        MockAppSwitchHandler.cannedCanHandle = false

        let urlContext = MockOpenURLContext(url: URL(string: "fake://url")!)

        let handled = BTAppSwitch.handleOpenURLContext(urlContext)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppSwitchHandler.lastHandleAppSwitchReturnURL)
    }

    func testHandleOpenURL_withNoAppSwitching_returnsFalse() {
        let handled = BTAppSwitch.handleOpen(URL(string: "scheme://")!)
        XCTAssertFalse(handled)
    }

}

class MockAppSwitchHandler: BTAppSwitchHandler {
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
