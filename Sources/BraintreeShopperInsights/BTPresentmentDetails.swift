import Foundation

public enum BTExperimentType: String {
    case test = "test"
    case control = "control"
}

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
