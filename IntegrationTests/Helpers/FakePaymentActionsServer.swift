import Foundation
import CardinalMobile
import OHHTTPStubs
@testable import BraintreePaymentActions

/// Stands in for the Payment Actions GraphQL server, which isn't deployed to sandbox yet, so the
/// 3DS integration tests can still run the real SDK drive loop end to end. Only the Payment Actions
/// GraphQL operations are stubbed; configuration fetches still hit the real sandbox.
///
/// TODO: Remove this file, `MockCardinalSession`, and the tests that use them once the sandbox schema is
/// deployed, and point `BTPaymentActionsThreeDSecure_IntegrationTests` at real sandbox flows.
final class FakePaymentActionsServer: @unchecked Sendable {

    enum ConfirmationMethod {
        case automatic
        case manual
    }

    enum CaptureMethod {
        case automatic
        case manual
    }

    /// Whether the simulated issuer asks the shopper to complete a challenge after device data collection.
    enum Authentication {
        case challenge
        case frictionless
    }

    private enum Stage {
        case readyForConfirmation
        case awaitingDeviceData
        case awaitingChallenge
        case authorized
    }

    private enum Operation {
        case setPaymentMethod
        case getPaymentAction
        case signalCustomerActionComplete

        init?(query: String) {
            if query.contains("mutation SetPaymentActionPaymentMethod") {
                self = .setPaymentMethod
            } else if query.contains("mutation SignalCustomerActionComplete") {
                self = .signalCustomerActionComplete
            } else if query.contains("query GetPaymentAction") {
                self = .getPaymentAction
            } else {
                return nil
            }
        }
    }

    // MARK: - Properties

    private let confirmation: ConfirmationMethod
    private let capture: CaptureMethod
    private let authentication: Authentication
    private let softDeclines: Bool
    private let paymentActionID = "fake-pa-\(UUID().uuidString.prefix(8).lowercased())"

    private let lock = NSLock()
    private var descriptor: HTTPStubsDescriptor?
    private var stage = Stage.awaitingDeviceData
    private var hasAuthenticated = false
    private var version = 0
    private var processingResponsesRemaining = 0
    private var receivedCompletedActions: [String] = []

    // MARK: - Initializer

    init(
        confirmation: ConfirmationMethod = .automatic,
        capture: CaptureMethod = .automatic,
        authentication: Authentication = .challenge,
        softDeclines: Bool = false
    ) {
        self.confirmation = confirmation
        self.capture = capture
        self.authentication = authentication
        self.softDeclines = softDeclines

        descriptor = stub(
            condition: { [weak self] in self?.handles($0) ?? false },
            response: { [weak self] in self?.respond(to: $0) ?? Self.failure("Fake server is no longer active.") }
        )
    }

    deinit {
        if let descriptor {
            HTTPStubs.removeStub(descriptor)
        }
    }

    // MARK: - Test Controls

    /// The `signalCustomerActionComplete` payloads received so far, in order (`deviceDataCollection`, `challenge`).
    var completedActions: [String] {
        withLock { receivedCompletedActions }
    }

    /// Plays the merchant server confirming a Payment Action that's `READY_FOR_CONFIRMATION`.
    func confirm() {
        withLock {
            guard stage == .readyForConfirmation else { return }
            stage = hasAuthenticated ? .authorized : .awaitingDeviceData
            if softDeclines {
                processingResponsesRemaining = 2
            }
        }
    }

    // MARK: - Request Handling

    private func handles(_ request: URLRequest) -> Bool {
        guard request.httpMethod == "POST", let query = Self.parse(request)?.query else { return false }
        return Operation(query: query) != nil
    }

    private func respond(to request: URLRequest) -> HTTPStubsResponse {
        guard let body = Self.parse(request), let operation = Operation(query: body.query) else {
            return Self.failure("Unrecognized Payment Actions request.")
        }

        withLock {
            switch operation {
            case .setPaymentMethod:
                hasAuthenticated = false
                stage = confirmation == .manual ? .readyForConfirmation : .awaitingDeviceData
                if softDeclines && confirmation == .automatic {
                    // This response and the next two fetches report `PROCESSING`.
                    processingResponsesRemaining = 3
                }
            case .getPaymentAction:
                break
            case .signalCustomerActionComplete:
                applySignal(Self.completedAction(from: body.variables))
            }
        }

        return Self.success(withLock { responseBody(for: operation) })
    }

    /// Callers hold the lock.
    private func applySignal(_ completedAction: String?) {
        guard let completedAction else { return }
        receivedCompletedActions.append(completedAction)

        switch completedAction {
        case "deviceDataCollection":
            if authentication == .challenge {
                stage = .awaitingChallenge
            } else {
                finishAuthentication()
            }
        case "challenge":
            finishAuthentication()
        default:
            break
        }
    }

    /// Callers hold the lock.
    private func finishAuthentication() {
        hasAuthenticated = true
        stage = confirmation == .manual ? .readyForConfirmation : .authorized
    }

    // MARK: - Responses

    /// Callers hold the lock.
    private func responseBody(for operation: Operation) -> [String: Any] {
        version += 1
        var paymentAction: [String: Any] = ["id": paymentActionID, "version": version]

        switch stage {
        case .readyForConfirmation:
            paymentAction["status"] = "READY_FOR_CONFIRMATION"
        case .awaitingDeviceData where processingResponsesRemaining > 0:
            // The unauthenticated attempt is still being processed; once it soft-declines, the server
            // asks the shopper to authenticate.
            processingResponsesRemaining -= 1
            paymentAction["status"] = "PROCESSING"
        case .awaitingDeviceData:
            paymentAction["status"] = "REQUIRES_CUSTOMER_ACTION"
            paymentAction["nextAction"] = [
                "__typename": "PaymentActionThreeDSecureAuthentication",
                "bin": "400000"
            ]
        case .awaitingChallenge:
            paymentAction["status"] = "REQUIRES_CUSTOMER_ACTION"
            paymentAction["nextAction"] = [
                "__typename": "PaymentActionThreeDSecureChallenge",
                "acsUrl": "https://acs.example.com/challenge",
                "challengePayload": "fake-challenge-payload",
                "mpiTransactionId": "fake-mpi-transaction-id"
            ]
        case .authorized:
            paymentAction["status"] = capture == .manual ? "REQUIRES_CAPTURE" : "SUCCEEDED"
        }

        switch operation {
        case .setPaymentMethod:
            return ["setPaymentActionPaymentMethod": ["paymentAction": paymentAction]]
        case .signalCustomerActionComplete:
            return ["signalCustomerActionComplete": ["paymentAction": paymentAction]]
        case .getPaymentAction:
            return ["paymentAction": paymentAction]
        }
    }

    private static func success(_ data: [String: Any]) -> HTTPStubsResponse {
        let body = (try? JSONSerialization.data(withJSONObject: ["data": data])) ?? Data()
        return HTTPStubsResponse(data: body, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    private static func failure(_ message: String) -> HTTPStubsResponse {
        let body = (try? JSONSerialization.data(withJSONObject: ["errors": [["message": message]]])) ?? Data()
        return HTTPStubsResponse(data: body, statusCode: 500, headers: ["Content-Type": "application/json"])
    }

    // MARK: - Parsing

    private static func parse(_ request: URLRequest) -> (query: String, variables: [String: Any])? {
        guard let data = request.ohhttpStubs_httpBody,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let query = json["query"] as? String else {
            return nil
        }
        return (query, json["variables"] as? [String: Any] ?? [:])
    }

    private static func completedAction(from variables: [String: Any]) -> String? {
        guard let input = variables["input"] as? [String: Any],
            let action = input["customerActionComplete"] as? [String: Any] else {
            return nil
        }
        if action["deviceDataCollection"] != nil {
            return "deviceDataCollection"
        }
        return action["challenge"] != nil ? "challenge" : nil
    }

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}

/// Cardinal stand-in for the integration tests, which can't present a real challenge UI. Duplicated
/// from `BraintreePaymentActionsTests` since test targets can't share files.
///
/// TODO: Remove along with `FakePaymentActionsServer` once real sandbox flows replace the fake server.
final class MockCardinalSession: CardinalSessionTestable {

    /// The action code Cardinal "reports" when the challenge completes. `nil` leaves the challenge pending.
    var actionCodeToDeliver: CardinalResponseActionCode? = .success

    func configure(_ sessionConfig: CardinalSessionConfiguration) { }

    func setup(
        jwtString: String,
        completed didCompleteHandler: @escaping CardinalSessionSetupDidCompleteHandler,
        validated didValidateHandler: @escaping CardinalSessionSetupDidValidateHandler
    ) {
        didCompleteHandler("fake-df-reference-id")
    }

    func continueWith(transactionId: String, payload: String, validationDelegate: CardinalValidationDelegate) {
        guard let actionCodeToDeliver,
              let provider = validationDelegate as? BTPaymentActionThreeDSecureProvider else {
            return
        }
        provider.resolveChallenge(actionCode: actionCodeToDeliver, serverJWT: "fake-server-jwt")
    }
}

struct ActiveApplicationStateProvider: ApplicationStateProviding {

    let isApplicationActive = true
}
