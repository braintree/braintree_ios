//
//  AtomicLoggerEventModel.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

public struct AtomicLoggerEventModel {
    let metricType: AtomicLoggerMetricEventType
    let domain: AtomicLoggerDomain?
    let startDomain: AtomicLoggerDomain?
    let wasResumed: String?
    let isCrossApp: String?
    let interaction: String
    let status: String?
    let interactionType: String?
    let navType: String?
    let task: String?
    let flow: String?
    let viewName: String?
    let startViewName: String?
    let startTask: String?
    let startPath: String?
    let path: String?
    let atomicLibVersion: String? = AtomicCoreConstants.version
    let guid: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    init(metricType: AtomicLoggerMetricEventType, domain: AtomicLoggerDomain? = nil, startDomain: AtomicLoggerDomain? = nil, wasResumed: String? = nil, isCrossApp: String? = nil, interaction: String, status: String? = nil, interactionType: String? = nil, navType: String? = nil, task: String? = nil, flow: String? = nil, viewName: String? = nil, startViewName: String? = nil, startTask: String? = nil, startPath: String? = nil, path: String? = nil) {
        self.metricType = metricType
        self.domain = domain
        self.startDomain = startDomain
        self.wasResumed = wasResumed
        self.isCrossApp = isCrossApp
        self.interaction = interaction
        self.status = status
        self.interactionType = interactionType
        self.navType = navType
        self.task = task
        self.flow = flow
        self.viewName = viewName
        self.startViewName = startViewName
        self.startTask = startTask
        self.startPath = startPath
        self.path = path
    }
}

extension AtomicLoggerEventModel {
    public static func getPayWithPayPalCIStart(task: String, flow: String) -> AtomicLoggerEventModel {
        return .init(metricType: .start,
                     domain: .btSDK,
                     interaction: AtomicCoreConstants.payWithPaypal,
                     interactionType: "click",
                     navType: "navigate",
                     task: task,
                     flow: flow,
                     path: "/merchant_app/pay/")
    }
    
    public static func getPayWithPayPalEnd(task: String, flow: String) -> AtomicLoggerEventModel {
        return .init(metricType: .end, interaction: AtomicCoreConstants.payWithPaypal)
    }
}


public enum AtomicLoggerMetricEventType {
    case start
    case end
    case exponentialTime
    
    var metricEventName: String {
        switch self {
        case .start:
            return "ui_wait_start"
        case .end:
            return "ui_wait_end"
        case .exponentialTime:
            return "user_wait_time_exponential"
        }
    }
    
    var metricId: String {
        switch self {
        case .start, .end:
            return "pp.xo.ui.ci.count"
        case .exponentialTime:
            return "pp.xo.ui.ci.timing.exponential"
        }
    }
    
    var metricType: String {
        switch self {
        case .start, .end:
            return "counter"
        case .exponentialTime:
            return "histogram"
        }
    }
}

public enum AtomicLoggerDomain: String {
    case xo = "xo"
    case btSDK = "bt-sdk"
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((timeIntervalSince1970 * 1000.0).rounded())
    }
}
