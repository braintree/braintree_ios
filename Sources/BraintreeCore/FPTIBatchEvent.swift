import Foundation

// MARK: - Welcome
struct FPTIBatchEvent: Codable {
    let events: [Event]
}

// MARK: - Event
struct Event: Codable {
    let batchParams: BatchParams
    let eventParams: [EventParam]

    enum CodingKeys: String, CodingKey {
        case batchParams = "batch_params"
        case eventParams = "event_params"
    }
}

// MARK: - BatchParams
struct BatchParams: Codable {
    let appID, appName, cSDKVer, clientOS: String
    let comp, deviceManufacturer, eventSource, iosPackageManager: String
    let isSimulator: Bool
    let mapv, merchantID, mobileDeviceModel, platform: String
    let sessionID, tenantName: String

    enum CodingKeys: String, CodingKey {
        case appID = "app_id"
        case appName = "app_name"
        case cSDKVer = "c_sdk_ver"
        case clientOS = "client_os"
        case comp
        case deviceManufacturer = "device_manufacturer"
        case eventSource = "event_source"
        case iosPackageManager = "ios_package_manager"
        case isSimulator = "is_simulator"
        case mapv
        case merchantID = "merchant_id"
        case mobileDeviceModel = "mobile_device_model"
        case platform
        case sessionID = "session_id"
        case tenantName = "tenant_name"
    }
}

// MARK: - EventParam
struct EventParam: Codable {
    let eventName, t: String

    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case t
    }
}
