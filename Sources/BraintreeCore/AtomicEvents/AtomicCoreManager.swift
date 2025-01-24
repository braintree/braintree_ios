//
//  AtomicCoreManager.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

final class AtomicCoreManager {
    public static let shared = AtomicCoreManager()
    private let atomicEventLogger: AtomicEventLoggerProviding
    private let eventTimerManager: AtomicEventTimerProviding
    private let payloadConstructor: AtomicPayloadConstructorProviding
        
    private init(atomicEventLogger: AtomicEventLoggerProviding = AtomicEventLogger(),
                 eventTimerManager: AtomicEventTimerProviding = AtomicEventTimerHandler(),
                 payloadConstructor: AtomicPayloadConstructorProviding = AtomicPayloadConstructor()) {
        self.atomicEventLogger = atomicEventLogger
        self.eventTimerManager = eventTimerManager
        self.payloadConstructor = payloadConstructor
    }
    
    //MARK: - Track start and End
    func logCIStartEvent(_ event: AtomicLoggerEventModel) {
        guard let parameters = payloadConstructor.getStartEventPayload(model: event) else {
            return
        }
        let interaction = event.interaction
        eventTimerManager.recordStartTime(for: interaction)
        atomicEventLogger.log(interaction, with: parameters)
    }
    
    func logCIEndEvent(_ event: AtomicLoggerEventModel, startTime: Int64? = nil) {
        let interaction = event.interaction
        let startTime = startTime ?? eventTimerManager.getStartTime(for: interaction)
        guard let parameters = payloadConstructor.getEndEventPayload(model: event,startTime: startTime) else {
            return
        }
        atomicEventLogger.log(interaction, with: parameters)
    }
}
