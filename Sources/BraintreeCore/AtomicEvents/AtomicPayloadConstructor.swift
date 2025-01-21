//
//  AtomicPayloadConstructor.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

protocol AtomicPayloadConstructorProviding{
    func getStartEventPayload(model : AtomicLoggerEventModel) -> [[String : Any]]?
    func getEndEventPayload(model : AtomicLoggerEventModel, startTime : Int64?) -> [[String : Any]]?
}


struct AtomicPayloadConstructor : AtomicPayloadConstructorProviding{
    
    func getStartEventPayload(model : AtomicLoggerEventModel) -> [[String : Any]]?{
        let start = getPayload(model: model)
        return convertJson(payloads: [start])
    }
    
    func getEndEventPayload(model : AtomicLoggerEventModel, startTime : Int64? = nil) -> [[String : Any]]?{
        var payloads : [AnalyticsPayload] = []
        let end = getPayload(model: model)
        payloads.append(end)
        if let startTime = startTime{
            let timer = getHistogramPayload(endEventPayload: end, startTime: startTime)
            payloads.append(timer)
        }
        
        return convertJson(payloads: payloads)
    }
    
    private func getHistogramPayload(endEventPayload : AnalyticsPayload,startTime: Int64) -> AnalyticsPayload{
        var timerEventPayload = endEventPayload
        let metricType = AtomicLoggerMetricEventType.exponentialTime
        timerEventPayload.value.metricEventName = metricType.metricEventName
        timerEventPayload.value.metricType = metricType.metricType
        timerEventPayload.value.metricId = metricType.metricId
        timerEventPayload.value.metricValue = Date().millisecondsSince1970 - startTime
        return timerEventPayload
    }
    
    private func getPayload(model : AtomicLoggerEventModel) -> AnalyticsPayload{
        return .init(type: "metric",
                     value: .init(
                        dimensions: .init(
                            domain: model.domain?.rawValue,
                            startDomain: model.startDomain?.rawValue,
                            wasResumed: model.wasResumed,
                            isCrossApp: model.isCrossApp,
                            interaction: model.interaction,
                            status: model.status,
                            interactionType: model.interactionType,
                            navType: model.navType,
                            task: model.task,
                            flow: model.flow,
                            viewName: model.viewName,
                            startViewName: model.startViewName,
                            startTask: model.startTask,
                            startPath: model.startPath,
                            path: model.path,
                            atomicLibVersion: model.atomicLibVersion
                        ),
                        metricEventName: model.metricType.metricEventName,
                        metricId: model.metricType.metricId,
                        metricType: model.metricType.metricType))
    }
    
    private func convertJson(payloads : [AnalyticsPayload]) -> [[String : Any]]?{
        do {
                let jsonData = try JSONEncoder().encode(payloads)
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                    return jsonArray
                }
            } catch {
                print("Error during conversion: \(error)")
            }
            return nil
    }
    
}


struct AnalyticsPayload: Codable {
    var type: String
    var value: PayloadValue
    
    struct PayloadValue: Codable {
        var dimensions: Dimensions
        var metricEventName: String
        var metricId: String
        var metricType: String
        var metricValue : Int64?
        
        struct Dimensions: Codable {
            var domain: String?
            var startDomain : String?
            var wasResumed : String?
            var isCrossApp : String?
            var interaction: String
            var status : String?
            var interactionType: String?
            var navType: String?
            var task: String?
            var flow: String?
            var viewName : String?
            var startViewName : String?
            var startTask : String?
            var startPath : String?
            var path: String?
            var atomicLibVersion: String?
            var component : String? = "ios_app"
            
            enum CodingKeys: String, CodingKey {
                case domain
                case startDomain = "start_domain"
                case wasResumed = "was_resumed"
                case isCrossApp = "is_cross_app"
                case status
                case interaction
                case interactionType = "interaction_type"
                case navType = "nav_type"
                case task
                case flow
                case viewName = "view_name"
                case startViewName = "start_view_name"
                case startTask = "start_task"
                case startPath = "start_path"
                case path
                case atomicLibVersion = "atomic_lib_version"
                case component
            }
        }
    }
}
