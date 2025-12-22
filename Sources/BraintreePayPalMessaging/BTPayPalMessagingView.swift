import UIKit
import SwiftUI
import PayPalMessages

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Use `BTPayPalMessagingView` to display PayPal messages to promote offers such as Pay Later and PayPal Credit to customers.
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public class BTPayPalMessagingView: UIView {

    // MARK: - Properties

    public weak var delegate: BTPayPalMessagingDelegate?

    var messageView: PayPalMessageView?
    var apiClient: BTAPIClient

    /// Cached client context derived from Braintree remote configuration.
    /// This enables a synchronous fast-path on subsequent `start(_:)` calls for the same view instance.
    private var cachedClientContext: ClientContext?

    /// A deterministic key for the latest requested state, used to ignore stale async callbacks.
    private var desiredKey: String?

    private struct ClientContext {
        let clientID: String
        let environment: PayPalMessages.Environment
    }

    // MARK: - Initializers

    ///  Initializes a `BTPayPalMessagingView`.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Method

    /// Creates a view to be displayed to promote offers such as Pay Later and PayPal Credit to customers.
    /// - Parameter request: an optional `BTPayPalMessagingRequest`
    /// - Warning: use `BTPayPalMessagingDelegate` protocol to receive notifications for events
    @discardableResult
    public func start(_ request: BTPayPalMessagingRequest) -> Result<Void, PayPalMessageError>? {
        PayPalMessageConfig.setGlobalAnalytics(
            integrationName: "BT_SDK",
            integrationVersion: BTCoreConstants.braintreeSDKVersion
        )

        apiClient.sendAnalyticsEvent(BTPayPalMessagingAnalytics.started)

        let authKey = apiClient.authorization.originalValue
        let key = makeDesiredKey(authKey: authKey, request: request)
        desiredKey = key

        // Fast-path: if we already resolved clientID/environment for this view, build config and apply synchronously.
        if let cachedClientContext {
            let config = makeMessageConfig(request: request, context: cachedClientContext)

            // Enforce "latest wins" even on the sync path (extra safety against re-entrancy).
            guard desiredKey == key else { return nil }

            if let messageView {
                return messageView.setConfig(config)
            }

            setupMessageView(with: config, expectedKey: key)
            return nil
        }

        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            // Ignore stale completion if `start` was called again with a different request.
            guard self.desiredKey == key else { return }

            if let error {
                self.notifyFailure(with: error)
                return
            }

            guard let configuration else {
                self.notifyFailure(with: BTPayPalMessagingError.fetchConfigurationFailed)
                return
            }

            guard let clientID = configuration.json?["paypal"]["clientId"].asString() else {
                self.notifyFailure(with: BTPayPalMessagingError.payPalClientIDNotFound)
                return
            }

            let context = ClientContext(
                clientID: clientID,
                environment: configuration.environment == "production" ? .live : .sandbox)

            self.cachedClientContext = context

            let messageConfig = self.makeMessageConfig(request: request, context: context)
            self.setupMessageView(with: messageConfig, expectedKey: key)
        }

        return nil
    }

    private func makeMessageConfig(request: BTPayPalMessagingRequest, context: ClientContext) -> PayPalMessageConfig {
        let messageData = PayPalMessageData(
            clientID: context.clientID,
            environment: context.environment,
            amount: request.amount,
            pageType: request.pageType?.pageTypeRawValue,
            offerType: request.offerType?.offerTypeRawValue
        )

        messageData.buyerCountry = request.buyerCountry

        return PayPalMessageConfig(
            data: messageData,
            style: PayPalMessageStyle(
                logoType: request.logoType.logoTypeRawValue,
                color: request.color.messageColorRawValue,
                textAlign: request.textAlignment.textAlignmentRawValue
            )
        )
    }

    private func makeDesiredKey(authKey: String, request: BTPayPalMessagingRequest) -> String {
        let pageTypeKey = request.pageType.map { String(describing: $0.pageTypeRawValue) } ?? ""
        let offerTypeKey = request.offerType.map { String(describing: $0.offerTypeRawValue) } ?? ""
        let amount = request.amount ?? 0

        return [
            authKey,
            "amount=\(amount)",
            "buyerCountry=\(request.buyerCountry ?? "")",
            "pageType=\(pageTypeKey)",
            "offerType=\(offerTypeKey)",
            "logoType=\(request.logoType.logoTypeRawValue)",
            "color=\(request.color.messageColorRawValue)",
            "textAlign=\(request.textAlignment.textAlignmentRawValue)"
        ].joined(separator: "|")
    }

    private func setupMessageView(with config: PayPalMessageConfig, expectedKey: String) {
        // Enforce "latest wins" at the final application boundary.
        guard
            messageView == nil,
            desiredKey == expectedKey
        else { return }

        let payPalMessageView = PayPalMessageView(config: config, stateDelegate: self, eventDelegate: self)
        payPalMessageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(payPalMessageView)

        NSLayoutConstraint.activate([
            payPalMessageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            payPalMessageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            payPalMessageView.topAnchor.constraint(equalTo: topAnchor),
            payPalMessageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        messageView = payPalMessageView
    }

    private func notifyFailure(with error: Error) {
        apiClient.sendAnalyticsEvent(BTPayPalMessagingAnalytics.failed, errorDescription: error.localizedDescription)
        delegate?.onError(self, error: error)
    }
}

// MARK: - UIViewRepresentable protocol conformance

public extension BTPayPalMessagingView {

    /// PayPal Messaging for SwiftUI
    struct Representable: UIViewRepresentable {

        private let apiClient: BTAPIClient
        private let delegate: BTPayPalMessagingDelegate?

        private var request = BTPayPalMessagingRequest()

        ///  Initializes a `BTPayPalMessagingView`.
        /// - Parameters:
        ///   - authorization: A valid client token or tokenization key used to authorize API calls.
        ///   - request: an optional `BTPayPalMessagingRequest`
        ///   - delegate: an optional `BTPayPalMessagingDelegate`
        public init(
            authorization: String,
            request: BTPayPalMessagingRequest = BTPayPalMessagingRequest(),
            delegate: BTPayPalMessagingDelegate? = nil
        ) {
            self.apiClient = BTAPIClient(authorization: authorization)
            self.request = request
            self.delegate = delegate
        }

        // MARK: - UIViewRepresentable Methods

        public func makeUIView(context: Context) -> BTPayPalMessagingView {
            let payPalMessagingView = BTPayPalMessagingView(authorization: apiClient.authorization.originalValue)
            payPalMessagingView.delegate = delegate
            _ = payPalMessagingView.start(request)
            return payPalMessagingView
        }

        public func updateUIView(_ view: BTPayPalMessagingView, context: Context) {
            view.apiClient = apiClient
        }
    }
}

// MARK: - PayPalMessageViewEventDelegate and PayPalMessageViewStateDelegate protocol conformance

extension BTPayPalMessagingView: PayPalMessageViewEventDelegate, PayPalMessageViewStateDelegate {

    public func onClick(_ paypalMessageView: PayPalMessages.PayPalMessageView) {
        delegate?.didSelect(self)
    }

    public func onApply(_ paypalMessageView: PayPalMessages.PayPalMessageView) {
        delegate?.willApply(self)
    }

    public func onLoading(_ paypalMessageView: PayPalMessages.PayPalMessageView) {
        delegate?.willAppear(self)
    }

    public func onSuccess(_ paypalMessageView: PayPalMessages.PayPalMessageView) {
        apiClient.sendAnalyticsEvent(BTPayPalMessagingAnalytics.succeeded)
        delegate?.didAppear(self)
    }

    public func onError(_ paypalMessageView: PayPalMessages.PayPalMessageView, error: PayPalMessages.PayPalMessageError) {
        apiClient.sendAnalyticsEvent(BTPayPalMessagingAnalytics.failed, errorDescription: error.localizedDescription)
        delegate?.onError(self, error: error)
    }
}
