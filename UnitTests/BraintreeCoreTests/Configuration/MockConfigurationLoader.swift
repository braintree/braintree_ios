@testable import BraintreeCore
import Foundation

class MockConfigurationLoader: ConfigurationLoader {
    
    private let mockConfig: BTConfiguration?
    private let mockError: Error?
    
    init(http: BTHTTP, mockConfig: BTConfiguration? = nil, mockError: Error? = nil) {
        self.mockConfig = mockConfig
        self.mockError = mockError
        super.init(http: http)
    }
    
    override func getConfig(completion: @escaping (BTConfiguration?, Error?) -> Void) {
        if let error = mockError {
            completion(nil, error)
        } else {
            completion(mockConfig, nil)
        }
    }
    
    override func getConfig() async throws -> BTConfiguration {
        if let error = mockError {
            throw error
        } else if let config = mockConfig {
            return config
        } else {
            throw BTAPIClientError.configurationUnavailable
        }
    }
}
