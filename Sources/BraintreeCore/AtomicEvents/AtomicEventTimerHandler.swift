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
    func removeStartTime(for interaction: String)
}

class AtomicEventTimerHandler: AtomicEventTimerProviding {
    private var startTimes: [String: Int64] = [:]
    
    // This clean up time interval needs to be decided upon.
    private var timeIntervalInSeconds = 30
    private let timer: RepeatingTimer
    
    var allowedDurationInMilliseconds: Int64 {
        return Int64(timeIntervalInSeconds * 1000)
    }
    
    init() {
        timer = RepeatingTimer(timeInterval: timeIntervalInSeconds)
        timer.eventHandler = { [weak self] in
            guard let self else { return }
            self.removePastUnendedEvents()
        }
        timer.resume()
    }
    
    deinit {
        timer.suspend()
    }
     
    func recordStartTime(for interaction: String) {
        startTimes[interaction] = Date().millisecondsSince1970
    }
    
    func getStartTime(for interaction: String) -> Int64? {
        return startTimes[interaction]
    }
    
    func removeStartTime(for interaction: String) {
        startTimes.removeValue(forKey: interaction)
    }
    
    private func removePastUnendedEvents() {
        // MARK: Need to trigger an end event from this place.
        guard !startTimes.isEmpty else { return }
        
        let timeInterval = Date().millisecondsSince1970 - allowedDurationInMilliseconds
        var interactionsToRemove = [String]()
        
        startTimes.keys.forEach {
            if let interactionStartTime = getStartTime(for: $0), interactionStartTime < timeInterval {
                interactionsToRemove.append($0)
            }
        }
        
        interactionsToRemove.forEach {
            removeStartTime(for: $0)
        }
    }
}
