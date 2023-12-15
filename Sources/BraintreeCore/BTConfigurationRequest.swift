/// The POST body for `v1/configuration`
struct BTConfigurationRequest: Encodable {
    
    private let configVersion: String
    
    init(version: String) {
        self.configVersion = version
    }
}
