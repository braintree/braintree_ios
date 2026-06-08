import XCTest
import BraintreeCard
import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeUIComponents

@MainActor
final class CardFieldsViewModelTests: XCTestCase {

    private var mockAPIClient = MockAPIClient(authorization: "development_testing_tokenization_key_sandbox")
    private var viewModel = CardFieldsViewModel(
        authorization: "development_testing_tokenization_key_sandbox",
        card: BTCard()
    ) { _, _ in }

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_testing_tokenization_key_sandbox")
        viewModel = CardFieldsViewModel(
            authorization: "development_testing_tokenization_key_sandbox",
            card: BTCard()
        ) { _, _ in }
        viewModel.apiClient = mockAPIClient
    }

    // MARK: - Analytics

    func testSendAnalyticsEvent_cardFieldsPresented_postsCorrectEvent() {
        viewModel.sendAnalyticsEvent(UIComponentsAnalytics.cardFieldsPresented)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(UIComponentsAnalytics.cardFieldsPresented))
    }

    func testTokenize_whenFormIsValid_postsSubmittedEvent() {
        viewModel.tokenize()

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(UIComponentsAnalytics.cardFieldsSelected))
    }
}
