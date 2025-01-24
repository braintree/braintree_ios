//
//  AtomicEventLogger.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

protocol AtomicEventLoggerProviding {
    func log(_ event: String, with properties: [[String: Any]])
}

class AtomicEventLogger: AtomicEventLoggerProviding {
    private var baseURLString: String = AtomicCoreConstants.URL.baseUrl
    
    init(baseURLString: String? = nil) {
        if let baseURLString {
            self.baseURLString = baseURLString
        }
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
            
            session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    debugPrint("Analytics Error: \(error.localizedDescription)")
                } else {
                    debugPrint("Analytics Event Sent: \(event)")
                }
            }.resume()
        } catch {
            debugPrint(error)
        }
    }
}
