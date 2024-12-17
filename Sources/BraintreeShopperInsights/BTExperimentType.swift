import Foundation

/// The experiment type that is sent to analytics to help improve the Shopper Insights feature experience.
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTExperimentType: String {

    /// The test experiment
    case test

    /// The control experiment
    case control

    public var formattedExperiment: String {
        """
            [
                { "exp_name" : "PaymentReady" }
                { "treatment_name" : "\(self.rawValue)" }
            ]
        """
    }
}
