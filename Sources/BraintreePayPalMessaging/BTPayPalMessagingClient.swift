import UIKit
import SwiftUI
import PayPalMessages

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Use `BTPayPalMessagingClient` to display PayPal messages to promote offers such as Pay Later and PayPal Credit to customers.
/// - Note: This module is in beta. It's public API may change or be removed in future releases.
public class BTPayPalMessagingClient: UIView {

    // MARK: - Properties

    public weak var delegate: BTPayPalMessagingDelegate?

    var apiClient: BTAPIClient

    // MARK: - Initializers

    ///  Initializes a PayPal Messaging client.
    /// - Parameter apiClient: The Braintree API client
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Method

    /// Creates a `BTPayPalMessagingClient` to be displayed to promote offers such as Pay Later and PayPal Credit to customers.
    /// - Parameter request: an optional `BTPayPalMessagingRequest`
    public func createView(_ request: BTPayPalMessagingRequest = BTPayPalMessagingRequest()) {
        apiClient.sendAnalyticsEvent(BTPayPalMessagingAnalytics.started)
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                delegate?.onError(self, error: error)
                return
            }

            guard let configuration else {
                delegate?.onError(self, error: BTPayPalMessagingError.fetchConfigurationFailed)
                return
            }

            guard let clientID = configuration.json?["paypal"]["clientId"].asString() else {
                delegate?.onError(self, error: BTPayPalMessagingError.payPalClientIDNotFound)
                return
            }

            let messageData = PayPalMessageData(
                clientID: clientID,
                environment: configuration.environment == "production" ? .live : .sandbox,
                amount: request.amount,
                placement: request.placement?.placementRawValue,
                offerType: request.offerType?.offerTypeRawValue
            )

            messageData.buyerCountry = request.buyerCountry

            let messageConfig = PayPalMessageConfig(
                data: messageData,
                style: PayPalMessageStyle(
                    logoType: request.logoType.logoTypeRawValue,
                    color: request.color.messageColorRawValue,
                    textAlignment: request.textAlignment.textAlignmentRawValue
                )
            )

            let messageView = PayPalMessageView(config: messageConfig, stateDelegate: self, eventDelegate: self)
            messageView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(messageView)

            NSLayoutConstraint.activate([
                messageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                messageView.topAnchor.constraint(equalTo: self.topAnchor),
                messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])

            return
        }
    }
}

// MARK: - UIViewRepresentable protocol conformance

public extension BTPayPalMessagingClient {

    /// PayPal Messaging for SwiftUI
    struct Representable: UIViewRepresentable {

        private let apiClient: BTAPIClient
        private let delegate: BTPayPalMessagingDelegate?

        private var request: BTPayPalMessagingRequest = BTPayPalMessagingRequest()
        
        ///  Initializes a PayPal Messaging client.
        /// - Parameters:
        ///   - apiClient: The Braintree API client
        ///   - request: an optional `BTPayPalMessagingRequest`
        ///   - delegate: an optional `BTPayPalMessagingDelegate`
        public init(apiClient: BTAPIClient, request: BTPayPalMessagingRequest = BTPayPalMessagingRequest(), delegate: BTPayPalMessagingDelegate? = nil) {
            self.apiClient = apiClient
            self.request = request
            self.delegate = delegate
        }

        // MARK: - UIViewRepresentable Methods

        public func makeUIView(context: Context) -> BTPayPalMessagingClient {
            let payPalMessagingView = BTPayPalMessagingClient(apiClient: apiClient)
            payPalMessagingView.createView(request)
            payPalMessagingView.delegate = delegate
            return payPalMessagingView
        }

        public func updateUIView(_ view: BTPayPalMessagingClient, context: Context) {
            view.apiClient = apiClient
        }
    }
}

// MARK: - PayPalMessageViewEventDelegate and PayPalMessageViewStateDelegate protocol conformance

extension BTPayPalMessagingClient: PayPalMessageViewEventDelegate, PayPalMessageViewStateDelegate {

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
        self.delegate?.onError(self, error: error)
    }
}
