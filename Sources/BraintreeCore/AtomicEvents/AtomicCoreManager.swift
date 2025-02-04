//
//  File.swift
//  
//
//  Created by Nitin Gupta on 04/02/25.
//

import Foundation

final class AtomicCoreManager {
    public static let shared = AtomicCoreManager()

    // Exposed for testing purposes.
    var atomicEventLogger: AtomicEventLoggerProviding
    let eventTimerManager: AtomicEventTimerProviding
    let payloadConstructor: AtomicPayloadConstructorProviding

    private init(atomicEventLogger: AtomicEventLoggerProviding = AtomicEventLogger(),
                 eventTimerManager: AtomicEventTimerProviding = AtomicEventTimerHandler(),
                 payloadConstructor: AtomicPayloadConstructorProviding = AtomicPayloadConstructor()) {
        self.atomicEventLogger = atomicEventLogger
        self.eventTimerManager = eventTimerManager
        self.payloadConstructor = payloadConstructor
    }

    //MARK: - Track start and End
    func logCIStartEvent(_ event: AtomicLoggerEventModel) {
        guard let parameters = payloadConstructor.getCIStartEventPayload(model: event) else {
            return
        }
        let interaction = event.interaction
        eventTimerManager.recordStartTime(for: interaction)
        atomicEventLogger.log(interaction, with: parameters)
    }

    func logCIEndEvent(_ event: AtomicLoggerEventModel, startTime: Int64? = nil) {
        let interaction = event.interaction
        let startTime = startTime ?? eventTimerManager.getStartTime(for: interaction)
        eventTimerManager.removeStartTime(for: interaction)
        guard let parameters = payloadConstructor.getCIEndEventPayload(model: event,startTime: startTime) else {
            return
        }
        atomicEventLogger.log(interaction, with: parameters)
    }

    func setAPIClient(_ apiClient: BTAPIClient) {
        atomicEventLogger.setAPIClient(apiClient)
    }
}
