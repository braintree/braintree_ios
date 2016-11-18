import XCTest

class BTCoreUtils_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBTCoreUtils_topViewControllerReturnsViewController() {
        let topInitialTopController = BTCoreUtils.topViewController()
        XCTAssertNotNil(topInitialTopController, "Top UIViewController should not be nil")

        let windowRootController = UIViewController()
        let secondWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        secondWindow.rootViewController = windowRootController
        secondWindow.makeKeyAndVisible()
        secondWindow.windowLevel = 100
        let topSecondTopController = BTCoreUtils.topViewController()
        XCTAssertNotEqual(topInitialTopController, topSecondTopController)
        XCTAssertEqual(windowRootController, topSecondTopController)
    }
}
