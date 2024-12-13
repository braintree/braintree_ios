import Foundation

/// - Warning: This class is in beta. It's public API may change or be removed in future releases.
public class BTPresentmentDetails {
    var buttonOrder: BTButtonOrder
    var experimentType: BTExperimentType
    var pageType: BTPageType

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
