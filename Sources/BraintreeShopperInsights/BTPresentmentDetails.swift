import Foundation

public class BTPresentmentDetails {

    /// The order or ranking in which payment buttons appear.
    var buttonOrder: BTButtonOrder

    /// The experiment type that is sent to analytics to help improve the Shopper Insights feature experience.
    var experimentType: BTExperimentType

    /// The type of page where the event occurred.
    var pageType: BTPageType

    /// Detailed information, including button order, experiment type, and page type about the payment button that
    /// is sent to analytics to help improve the Shopper Insights feature experience.
    /// - Warning: This class is in beta. It's public API may change or be removed in future releases.
    public init(
        buttonOrder: BTButtonOrder,
        experimentType: BTExperimentType,
        pageType: BTPageType
    ) {
        self.buttonOrder = buttonOrder
        self.experimentType = experimentType
        self.pageType = pageType
    }
}
