//
//  MockBTWebAuthenticationSession.swift
//  BraintreeTestShared
//
//  Created by Shropshire, Steven on 9/29/21.
//

import Foundation
import BraintreeCore

public class MockBTWebAuthenticationSession: BTWebAuthenticationSession {
    
    private struct StartInvocation: Equatable {
        let url: URL
        let callbackURLScheme: String
    }
    
    private var startInvocation: StartInvocation?
    private var completionHandler: ((URL?, Error?) -> Void)?
    
    public override func start(with url: URL, callbackURLScheme: String, completionHandler: @escaping (URL?, Error?) -> Void) {
        startInvocation = StartInvocation(url: url, callbackURLScheme: callbackURLScheme)
        self.completionHandler = completionHandler
    }
    
    public func didCallStart(with url: URL, callbackURLScheme: String) -> Bool {
        return startInvocation == StartInvocation(url: url, callbackURLScheme: callbackURLScheme)
    }
    
    public func simulateCompletion(with url: URL?, error: Error?) {
        completionHandler?(url, error)
    }
}
