import XCTest

class BTAppSwitch_Tests: XCTestCase {

    var appSwitch = BTAppSwitch.sharedInstance()

    override func setUp() {
        super.setUp()
        appSwitch = BTAppSwitch.sharedInstance()
    }
    
    override func tearDown() {
        MockAppSwitchHander.cannedCanHandle = false
        MockAppSwitchHander.lastCanHandleURL = nil
        MockAppSwitchHander.lastCanHandleSourceApplication = nil
        MockAppSwitchHander.lastHandleAppSwitchReturnURL = nil
        super.tearDown()
    }

    func testHandleOpenURL_whenHandlerIsRegistered_invokesCanHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHander.self)
        let expectedURL = NSURL(string: "fake://url")!
        let expectedSourceApplication = "fakeSourceApplication"

        BTAppSwitch.handleOpenURL(expectedURL, sourceApplication: expectedSourceApplication)

        XCTAssertEqual(MockAppSwitchHander.lastCanHandleURL!, expectedURL)
        XCTAssertEqual(MockAppSwitchHander.lastCanHandleSourceApplication!, expectedSourceApplication)
    }

    func testHandleOpenURL_whenHandlerCanHandleOpenURL_invokesHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHander.self)
        MockAppSwitchHander.cannedCanHandle = true
        let expectedURL = NSURL(string: "fake://url")!

        BTAppSwitch.handleOpenURL(expectedURL, sourceApplication: "not important")

        XCTAssertEqual(MockAppSwitchHander.lastHandleAppSwitchReturnURL!, expectedURL)
    }

    func testHandleOpenURL_whenHandlerCantHandleOpenURL_doesNotInvokeHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHander.self)
        MockAppSwitchHander.cannedCanHandle = false

        BTAppSwitch.handleOpenURL(NSURL(string: "fake://url")!, sourceApplication: "not important")

        XCTAssertNil(MockAppSwitchHander.lastHandleAppSwitchReturnURL)
    }
    
    func testHandleOpenURL_acceptsOptionalSourceApplication() {
        // This doesn't assert any behavior about nil source application. It only checks that the code will compile!
        let sourceApplication : String? = nil
        BTAppSwitch.handleOpenURL(NSURL(string: "fake://url")!, sourceApplication: sourceApplication)
    }
    
    func testHandleOpenURL_withNoAppSwitching() {
        let handled = BTAppSwitch().handleOpenURL(NSURL(string: "scheme://")!, sourceApplication: "com.yourcompany.hi")
        XCTAssertFalse(handled)
    }
}

class MockAppSwitchHander: BTAppSwitchHandler {
    static var cannedCanHandle = false
    static var lastCanHandleURL : NSURL? = nil
    static var lastCanHandleSourceApplication : String? = nil
    static var lastHandleAppSwitchReturnURL : NSURL? = nil

    @objc static func canHandleAppSwitchReturnURL(url: NSURL, sourceApplication: String) -> Bool {
        lastCanHandleURL = url
        lastCanHandleSourceApplication = sourceApplication
        return cannedCanHandle
    }

    @objc static func handleAppSwitchReturnURL(url: NSURL) {
        lastHandleAppSwitchReturnURL = url
    }
}