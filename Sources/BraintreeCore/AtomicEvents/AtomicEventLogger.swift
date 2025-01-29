//
//  AtomicEventLogger.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

protocol AtomicEventLoggerProviding {
    // Exposed in protocol for testing purposes
    var http: BTHTTP? { get set }
    
    func log(_ event: String, with properties: [[String: Any]])
    func setAPIClient(_ apiClient: BTAPIClient)
}

class AtomicEventLogger: AtomicEventLoggerProviding {
    private var baseURLString: String = AtomicCoreConstants.URL.baseUrl
    
    // Exposed for testing purposes
    var http: BTHTTP?
    
    init(baseURLString: String? = nil) {
        if let baseURLString {
            self.baseURLString = baseURLString
        }
    }
    
    func setAPIClient(_ apiClient: BTAPIClient) {
        http = BTHTTP(authorization: apiClient.authorization, customBaseURL: URL(string: baseURLString))
    }
    
    private lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    }()
    
    func log(_ event: String, with properties: [[String: Any]]) {
        guard let url = URL(string: "\(baseURLString)/xoplatform/logger/api/ae/") else {
            return
        }
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: properties)
            urlRequest.setValue(AtomicCoreConstants.URL.applicationJson,
                                forHTTPHeaderField: AtomicCoreConstants.URL.contentType)
            
            if let jsonData = urlRequest.httpBody,
               let jsonString = String(data: jsonData, encoding: .utf8) {
                debugPrint("Payload: " + jsonString)
            }
            
            http?.sendRequest(for: urlRequest, completion: { json, response, error in
                if let error {
                    debugPrint("Analytics Error: \(error.localizedDescription)")
                    return
                }
                
                debugPrint("Analytics Event Sent: \(event)")
            })
        } catch {
            debugPrint(error)
        }
    }
}
