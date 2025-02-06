import Foundation

///  `BTPresentmentDetails` Configure detailed information about the presented button.
/// - Warning: This class is in beta. It's public API may change or be removed in future releases.
public class BTPresentmentDetails {

    var buttonOrder: BTButtonOrder
    var experimentType: BTExperimentType
    var pageType: BTPageType

    /// Detailed information, including button order, experiment type, and page type about the payment button that
    /// is sent to analytics to help improve the Shopper Insights feature experience.
    /// - Warning: This class is in beta. It's public API may change or be removed in future releases.
    /// - Parameters:
    ///    - buttonOrder: The order or ranking in which payment buttons appear.
    ///    - experimentType: The experiment type that is sent to analytics to help improve the Shopper Insights feature experience.
    ///    - pageType: The type of page where the payment button is displayed or where an event occured.
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
