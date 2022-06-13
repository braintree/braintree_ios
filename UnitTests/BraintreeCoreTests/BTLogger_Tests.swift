import Foundation

@testable import BraintreeCoreSwift
import XCTest

class BTLogger_Tests: XCTestCase {
    
    func testLogger_whenInitialize_defaultLevelIsInfo() {
        XCTAssertEqual(BTLogger().level, BTLogLevel.info)
    }
    
    func testLog_whenLoggingAtOrBelowLevel_logsMessage() {
        let logger = BTLogger()
        var messagesLogged: [String] = []
        var message: String = ""
        
        BTLogLevel.allCases.forEach { level in
            message = "test \(level.rawValue)"
            
            if level.rawValue < BTLogLevel.debug.rawValue {
                XCTAssertTrue(level.rawValue <= logger.level.rawValue)
            }
            messagesLogged.append(message)
        }
        
        logger.critical(message)
        logger.error(message)
        logger.warning(message)
        logger.info(message)
        logger.debug(message)
        
        XCTAssertEqual(BTLogLevel.allCases.count, messagesLogged.count)
    }
}
