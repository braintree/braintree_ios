import XCTest

class BTDropInUtil_Tests: XCTestCase {
    //Flaky test
    func pendBTDropInUtil_topViewControllerReturnsViewController() {
        let topInitialTopController = BTDropInUtil.topViewController()
        XCTAssertNotNil(topInitialTopController, "Top UIViewController should not be nil")

        let windowRootController = UIViewController()
        let secondWindow = UIWindow(frame: UIScreen.main.bounds)
        secondWindow.rootViewController = windowRootController
        secondWindow.makeKeyAndVisible()
        secondWindow.windowLevel = 100
        let topSecondTopController = BTDropInUtil.topViewController()
        XCTAssertNotEqual(topInitialTopController, topSecondTopController)
        XCTAssertEqual(windowRootController, topSecondTopController)
    }
}
