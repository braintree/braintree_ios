import Foundation

class MockURLSessionTaskTransactionMetrics: URLSessionTaskTransactionMetrics, @unchecked Sendable {
    
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

class MockURLSessionTaskMetrics: URLSessionTaskMetrics, @unchecked Sendable {
    var mockTransactionMetrics: [URLSessionTaskTransactionMetrics]

    /// For testing only
    @available(iOS, deprecated: 13.0, message: "Required for mocking URLSessionTaskMetrics in tests")
    init(transactionMetrics: [URLSessionTaskTransactionMetrics]) {
        self.mockTransactionMetrics = transactionMetrics
    }
    
    override var transactionMetrics: [URLSessionTaskTransactionMetrics] {
        mockTransactionMetrics
    }
}
