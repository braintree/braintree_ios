import XCTest

extension XCTestCase {

    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 30) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate, evaluatedWith: element)
        
        waitForExpectations(timeout: timeout)
    }
    
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 30) {
        let existsPredicate = NSPredicate(format: "exists == true && hittable == true")
        
        expectation(for: existsPredicate, evaluatedWith: element)
        
        waitForExpectations(timeout: timeout)
    }
}

extension XCUIElement {

    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}
