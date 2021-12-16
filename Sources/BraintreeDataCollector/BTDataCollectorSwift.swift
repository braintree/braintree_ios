import Foundation

enum BTDataCollectorEnvironment {
    case development
    case QA
    case sandbox
    case production
}

@objcMembers public class BTDataCollectorSwift: NSObject {

    /// The Kount SDK device collector, exposed internally for testing
    var kount: KDataCollector
    
    /// 
    private var fraudMerchantID: String?
    private let apiClient: BTAPIClient
  
    /// Initializes a `BTDataCollector` instance with a BTAPIClient.
    /// - Parameter apiClient: The API client which can retrieve remote configuration for the data collector
    @objc(initWithAPIClient:)
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        super.init()

        setUpKountWithDebugOn(false)
    }
    
    func setUpKountWithDebugOn(_ debugLogging: Bool) {

    }
}
