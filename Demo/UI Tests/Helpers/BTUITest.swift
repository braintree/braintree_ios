import XCTest

extension XCTestCase {
    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 10,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate,
                                evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.record(XCTIssue(type: .assertionFailure,
                                     compactDescription: message,
                                     detailedDescription: nil,
                                     sourceCodeContext: XCTSourceCodeContext(location: XCTSourceCodeLocation(filePath: file, lineNumber: Int(line))),
                                     associatedError: error,
                                     attachments: []))
            }
        }
    }
    
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true && hittable == true")
        
        expectation(for: existsPredicate,
                                evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.record(XCTIssue(type: .assertionFailure,
                                     compactDescription: message,
                                     detailedDescription: nil,
                                     sourceCodeContext: XCTSourceCodeContext(location: XCTSourceCodeLocation(filePath: file, lineNumber: Int(line))),
                                     associatedError: error,
                                     attachments: []))
            }
        }
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
