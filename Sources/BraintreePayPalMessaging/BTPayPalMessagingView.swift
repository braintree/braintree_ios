import UIKit
import SwiftUI
import PayPalMessages

#if canImport(BraintreeCore)
import BraintreeCore
#endif

public class BTPayPalMessagingView: UIView {

    // MARK: - Properties

    public weak var delegate: BTPayPalMessagingDelegate?

    var apiClient: BTAPIClient

    // MARK: - Initializers

    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    public func createView(_ request: BTPayPalMessagingRequest? = nil) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.delegate?.onError(self, error: error)
                return
            }
            guard let configuration else {
                self.delegate?.onError(self, error: BTPayPalMessagingError.fetchConfigurationFailed)
                return
            }

            guard let clientID = configuration.json?["paypal"]["clientId"].asString() else {
                self.delegate?.onError(self, error: BTPayPalMessagingError.payPalClientIDNotFound)
                return
            }

            let messageData = PayPalMessageData(
                clientID: clientID,
                environment: configuration.environment == "production" ? .live : .sandbox,
                amount: request?.amount,
                placement: request?.placement?.placementRawValue,
                offerType: request?.offerType?.offerTypeRawValue
            )

            messageData.buyerCountry = request?.buyerCountry

            let messageConfig = PayPalMessageConfig(
                data: messageData,
                style: PayPalMessageStyle(
                    logoType: request?.logoType?.logoTypeRawValue ?? .inline,
                    color: request?.color?.messageColorRawValue ?? .black,
                    textAlignment: request?.textAlignment?.textAlignmentRawValue ?? .right
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

public extension BTPayPalMessagingView {

    struct Representable: UIViewRepresentable {

        private let apiClient: BTAPIClient
        private let request: BTPayPalMessagingRequest?
        private let delegate: BTPayPalMessagingDelegate?

        public init(apiClient: BTAPIClient, request: BTPayPalMessagingRequest? = nil, delegate: BTPayPalMessagingDelegate? = nil) {
            self.apiClient = apiClient
            self.request = request
            self.delegate = delegate
        }

        public func makeUIView(context: Context) -> BTPayPalMessagingView {
            let payPalMessagingView = BTPayPalMessagingView(apiClient: apiClient)
            payPalMessagingView.createView(request)
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
        delegate?.didAppear(self)
    }

    public func onError(_ paypalMessageView: PayPalMessages.PayPalMessageView, error: PayPalMessages.PayPalMessageError) {
        delegate?.onError(self, error: error)
    }
}
