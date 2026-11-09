import Foundation
import BraintreeCore
import OHHTTPStubs

/// Stands in for the Payment Actions GraphQL server only. The real SDK talks to it, and every 3DS
/// step is real: the challenge payload comes from the sandbox Gateway's lookup, and Cardinal
/// presents the actual challenge.
private struct EmptyObject: Encodable {}

private struct Challenge {

    let acsURL: String
    let payload: String
    let transactionID: String
}

private struct LookupBody: Encodable {

    let amount = "10.00"
    let dfReferenceId: String
    let challengeRequested = false
    let dataOnlyRequested = false
    let exemptionRequested = false
    let requestedThreeDSecureVersion = "2"
    let additionalInfo = EmptyObject()
    let customer = EmptyObject()
}

private final class ResultBox: @unchecked Sendable {

    var result: Result<Challenge?, Error>?
}

final class HybridPaymentActionsStub: @unchecked Sendable {

    private enum Stage {
        case requiresPaymentMethod
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

    private enum CompletedAction {
        case deviceData(dfReferenceID: String)
        case challenge
    }

    private static let lookupTimeout: TimeInterval = 45

    private let lock = NSLock()
    private var descriptor: HTTPStubsDescriptor?

    private var options = PaymentActionOptions()
    private var paymentActionID = ""
    private var clientToken = ""
    private var nonce = ""
    private var bin = ""
    private var stage = Stage.requiresPaymentMethod
    private var hasAuthenticated = false
    private var challenge: Challenge?
    private var version = 0
    private var lastFailureDescription: String?

    init() {
        descriptor = stub(
            condition: { [weak self] in self?.handles($0) ?? false },
            response: { [weak self] in self?.respond(to: $0) ?? Self.failure("Stub is no longer active.") }
        )
    }

    deinit {
        if let descriptor {
            HTTPStubs.removeStub(descriptor)
        }
    }

    // MARK: - Driven by the Demo

    /// Starts a new Payment Action and returns its ID.
    func begin(options: PaymentActionOptions, clientToken: String) -> String {
        withLock {
            self.options = options
            self.clientToken = clientToken
            paymentActionID = "hybrid-pa-\(UUID().uuidString.prefix(8).lowercased())"
            nonce = ""
            bin = ""
            stage = .requiresPaymentMethod
            hasAuthenticated = false
            challenge = nil
            version = 0
            return paymentActionID
        }
    }

    func setPaymentMethod(nonce: String, bin: String) {
        withLock {
            self.nonce = nonce
            self.bin = bin
        }
    }

    /// The reason the last stubbed response failed, if any. Reading it clears it.
    func takeLastFailure() -> String? {
        withLock {
            defer { lastFailureDescription = nil }
            return lastFailureDescription
        }
    }

    static func describe(_ error: Error) -> String {
        let nsError = error as NSError
        return String("\(nsError.localizedDescription) \(nsError.userInfo)".prefix(400))
    }

    /// Plays the merchant server confirming the Payment Action.
    func confirm() throws {
        let didConfirm: Bool = withLock {
            guard stage == .readyForConfirmation else { return false }
            stage = hasAuthenticated ? .authorized : .awaitingDeviceData
            return true
        }
        guard didConfirm else { throw PaymentActionsDemoError.unexpectedState }
    }

    // MARK: - Request Handling

    private func handles(_ request: URLRequest) -> Bool {
        let parsed = Self.parse(request)
        guard request.httpMethod == "POST", let body = parsed else { return false }
        return Operation(query: body.query) != nil
    }

    private func respond(to request: URLRequest) -> HTTPStubsResponse {
        guard let body = Self.parse(request), let operation = Operation(query: body.query) else {
            return Self.failure("Unrecognized Payment Actions request.")
        }

        do {
            switch operation {
            case .setPaymentMethod:
                withLock {
                    hasAuthenticated = false
                    challenge = nil
                    stage = options.confirmation == .manual ? .readyForConfirmation : .awaitingDeviceData
                }
            case .getPaymentAction:
                break
            case .signalCustomerActionComplete:
                try applySignal(Self.completedAction(from: body.variables))
            }
        } catch {
            withLock { lastFailureDescription = Self.describe(error) }
            return Self.failure(error.localizedDescription)
        }

        return Self.success(withLock { responseBody(for: operation) })
    }

    private func applySignal(_ completedAction: CompletedAction?) throws {
        switch completedAction {
        case .deviceData(let dfReferenceID):
            let (nonce, clientToken) = withLock { (self.nonce, self.clientToken) }
            let lookedUpChallenge = try lookUpChallenge(
                nonce: nonce,
                dfReferenceID: dfReferenceID,
                clientToken: clientToken
            )
            withLock {
                if let lookedUpChallenge {
                    challenge = lookedUpChallenge
                    stage = .awaitingChallenge
                } else {
                    finishAuthentication()
                }
            }
        case .challenge:
            withLock { finishAuthentication() }
        case nil:
            throw PaymentActionsDemoError.unexpectedState
        }
    }

    /// Callers hold the lock.
    private func finishAuthentication() {
        hasAuthenticated = true
        stage = options.confirmation == .manual ? .readyForConfirmation : .authorized
    }

    // MARK: - Real Gateway Lookup

    /// The existing 3DS flow's own lookup call, which is where a real challenge payload comes from.
    /// Returns `nil` when the Gateway decides no challenge is needed.
    private func lookUpChallenge(nonce: String, dfReferenceID: String, clientToken: String) throws -> Challenge? {
        let box = ResultBox()
        let semaphore = DispatchSemaphore(value: 0)

        // The stub's response block can't be async, so it waits here on a thread that isn't part of
        // Swift's cooperative pool while the lookup runs. The task runs at the waiting thread's priority
        // so that wait isn't a priority inversion.
        Task.detached(priority: .userInitiated) {
            do {
                let apiClient = BTAPIClient(authorization: clientToken)
                let encodedNonce = nonce.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? nonce
                let (json, _) = try await apiClient.post(
                    "v1/payment_methods/\(encodedNonce)/three_d_secure/lookup",
                    parameters: LookupBody(dfReferenceId: dfReferenceID)
                )

                let lookup = json?["lookup"]
                if let acsURL = lookup?["acsUrl"].asString(),
                    let payload = lookup?["pareq"].asString(),
                    let transactionID = lookup?["transactionId"].asString() {
                    box.result = .success(Challenge(acsURL: acsURL, payload: payload, transactionID: transactionID))
                } else {
                    box.result = .success(nil)
                }
            } catch {
                box.result = .failure(error)
            }
            semaphore.signal()
        }

        guard semaphore.wait(timeout: .now() + Self.lookupTimeout) == .success else {
            throw HybridStepError(step: "Gateway lookup", detail: "timed out")
        }
        return try (box.result ?? .success(nil)).get()
    }

    // MARK: - Responses

    /// Callers hold the lock.
    private func responseBody(for operation: Operation) -> [String: Any] {
        version += 1
        var paymentAction: [String: Any] = ["id": paymentActionID, "version": version]

        switch stage {
        case .requiresPaymentMethod:
            paymentAction["status"] = "REQUIRES_PAYMENT_METHOD"
        case .readyForConfirmation:
            paymentAction["status"] = "READY_FOR_CONFIRMATION"
        case .awaitingDeviceData:
            paymentAction["status"] = "REQUIRES_CUSTOMER_ACTION"
            paymentAction["nextAction"] = [
                "__typename": "PaymentActionThreeDSecureAuthentication",
                "bin": bin
            ]
        case .awaitingChallenge:
            paymentAction["status"] = "REQUIRES_CUSTOMER_ACTION"
            paymentAction["nextAction"] = [
                "__typename": "PaymentActionThreeDSecureChallenge",
                "acsUrl": challenge?.acsURL ?? "",
                "challengePayload": challenge?.payload ?? "",
                "mpiTransactionId": challenge?.transactionID ?? ""
            ]
        case .authorized:
            paymentAction["status"] = options.capture == .manual ? "REQUIRES_CAPTURE" : "SUCCEEDED"
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

    private static func completedAction(from variables: [String: Any]) -> CompletedAction? {
        guard let input = variables["input"] as? [String: Any],
            let action = input["customerActionComplete"] as? [String: Any] else {
            return nil
        }

        if let deviceData = action["deviceDataCollection"] as? [String: Any],
            let dfReferenceID = deviceData["dfReferenceId"] as? String {
            return .deviceData(dfReferenceID: dfReferenceID)
        }
        return action["challenge"] != nil ? .challenge : nil
    }

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}
