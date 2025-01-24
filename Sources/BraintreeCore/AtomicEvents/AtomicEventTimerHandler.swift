//
//  AtomicEventTimerHandler.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

protocol AtomicEventTimerProviding {
    func recordStartTime(for interaction: String)
    func getStartTime(for interaction: String) -> Int64?
}

class AtomicEventTimerHandler: AtomicEventTimerProviding {
    private var startTimes: [String: Int64] = [:]
     
    func recordStartTime(for interaction: String) {
        startTimes[interaction] = Date().millisecondsSince1970
    }
    
    func getStartTime(for interaction: String) -> Int64? {
        return startTimes[interaction]
    }
}
