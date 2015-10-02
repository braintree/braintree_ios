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

    func testHandleReturnURL_whenHandlerIsRegistered_invokesCanHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHander.self)
        let expectedURL = NSURL(string: "fake://url")!
        let expectedSourceApplication = "fakeSourceApplication"

        BTAppSwitch.handleOpenURL(expectedURL, sourceApplication: expectedSourceApplication)

        XCTAssertEqual(MockAppSwitchHander.lastCanHandleURL!, expectedURL)
        XCTAssertEqual(MockAppSwitchHander.lastCanHandleSourceApplication!, expectedSourceApplication)
    }

    func testHandleReturnURL_whenHandlerCanHandleReturnURL_invokesHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHander.self)
        MockAppSwitchHander.cannedCanHandle = true
        let expectedURL = NSURL(string: "fake://url")!

        BTAppSwitch.handleOpenURL(expectedURL, sourceApplication: "not important")

        XCTAssertEqual(MockAppSwitchHander.lastHandleAppSwitchReturnURL!, expectedURL)
    }

    func testHandleReturnURL_whenHandlerCantHandleReturnURL_doesNotInvokeHandleAppSwitchReturnURL() {
        appSwitch.registerAppSwitchHandler(MockAppSwitchHander.self)
        MockAppSwitchHander.cannedCanHandle = false

        BTAppSwitch.handleOpenURL(NSURL(string: "fake://url")!, sourceApplication: "not important")

        XCTAssertNil(MockAppSwitchHander.lastHandleAppSwitchReturnURL)
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