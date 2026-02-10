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

    // MARK: - Initializers

    ///  Initializes a `BTPayPalMessagingView`.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    public init(authorization: String) {
        apiClient = BTAPIClient(authorization: authorization)

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Method

    /// Creates a view to be displayed to promote offers such as Pay Later and PayPal Credit to customers.
    /// - Parameter request: an optional `BTPayPalMessagingRequest`
    /// - Warning: use `BTPayPalMessagingDelegate` protocol to receive notifications for events
    public func start(_ request: BTPayPalMessagingRequest = BTPayPalMessagingRequest()) {
        PayPalMessageConfig.setGlobalAnalytics(
            integrationName: "BT_SDK",
            integrationVersion: BTCoreConstants.braintreeSDKVersion
        )
        
        apiClient.sendAnalyticsEvent(BTPayPalMessagingAnalytics.started)

        Task { @MainActor in
            do {
                let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
                
                guard let clientID = configuration.json?["paypal"]["clientId"].asString() else {
                    notifyFailure(with: BTPayPalMessagingError.payPalClientIDNotFound)
                    return
                }

                let messageData = PayPalMessageData(
                    clientID: clientID,
                    environment: configuration.environment == "production" ? .live : .sandbox,
                    amount: request.amount,
                    pageType: request.pageType?.pageTypeRawValue,
                    offerType: request.offerType?.offerTypeRawValue
                )

                messageData.buyerCountry = request.buyerCountry

                let messageConfig = PayPalMessageConfig(
                    data: messageData,
                    style: PayPalMessageStyle(
                        logoType: request.logoType.logoTypeRawValue,
                        color: request.color.messageColorRawValue,
                        textAlign: request.textAlignment.textAlignmentRawValue
                    )
                )

                setupMessageView(with: messageConfig)
            } catch {
                notifyFailure(with: error)
            }
        }
    }
    
    private func setupMessageView(with config: PayPalMessageConfig) {
        if let messageView {
            messageView.setConfig(config)
        } else {
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
            apiClient = BTAPIClient(authorization: authorization)
            self.request = request
            self.delegate = delegate
        }

        // MARK: - UIViewRepresentable Methods

        public func makeUIView(context: Context) -> BTPayPalMessagingView {
            let payPalMessagingView = BTPayPalMessagingView(authorization: apiClient.authorization.originalValue)
            payPalMessagingView.start(request)
            payPalMessagingView.delegate = delegate
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
