import Foundation

class MockURLSessionTaskTransactionMetrics: URLSessionTaskTransactionMetrics {
    
    var mockConnectStartDate: Date?
    var mockFetchStartDate: Date?
    var mockResponseEndDate: Date?
    var mockRequest: URLRequest?
    
    override var connectStartDate: Date? {
        mockConnectStartDate
    }

    override var fetchStartDate: Date? {
        mockFetchStartDate
    }
    
    override var responseEndDate: Date? {
        mockResponseEndDate
    }
    
    override var request: URLRequest {
        mockRequest ?? URLRequest(url: URL(string: "https://example.com")!)
    }
}

class MockURLSessionTaskMetrics: URLSessionTaskMetrics {
    var mockTransactionMetrics: [URLSessionTaskTransactionMetrics]

    /// For testing only
    init(transactionMetrics: [URLSessionTaskTransactionMetrics]) {
        self.mockTransactionMetrics = transactionMetrics
    }
    
    override var transactionMetrics: [URLSessionTaskTransactionMetrics] {
        mockTransactionMetrics
    }
}
