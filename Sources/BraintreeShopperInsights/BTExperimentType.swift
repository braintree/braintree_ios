import Foundation

///
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTExperimentType: String {

    case test = "test"
    case control = "control"

    public var formattedExperiment: String {
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : \(self.rawValue) }
            ]
        """
    }
}
