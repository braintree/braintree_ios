//
//  AtomicLoggerEventModel.swift
//  BraintreeCore
//
//  Created by Karthikeyan Eswaramoorthi on 21/01/25.
//

import Foundation

public struct AtomicLoggerEventModel {
    var metricType: AtomicLoggerMetricEventType
    var domain: AtomicLoggerDomain?
    var startDomain: AtomicLoggerDomain?
    var wasResumed: String?
    var isCrossApp: String?
    var interaction: String
    var status: String?
    var interactionType: String?
    var navType: String?
    var task: String?
    var flow: String?
    var viewName: String?
    var startViewName: String?
    var startTask: String?
    var startPath: String?
    var path: String?
    var atomicLibVersion: String? = "0.16.0"
}

extension AtomicLoggerEventModel {
    public static func getPayWithPayPalCIStart(task: String, flow: String) -> AtomicLoggerEventModel {
        return .init(metricType: .start,
                     domain: .btSDK,
                     interaction: "Pay_With_Paypal",
                     interactionType: "click",
                     navType: "navigate",
                     task: task,
                     flow: flow,
                     path: "/merchant_app/pay/")
    }
    
    public static func getPayWithPayPalEnd(task: String, flow: String) -> AtomicLoggerEventModel {
        return .init(metricType: .end, interaction: "Pay_With_Paypal")
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
