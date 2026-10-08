import SwiftUI

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// A drop-in checkout component that shows the returning PayPal buyer's saved funding
/// instrument (FI) and lets them edit it, with optional inline Pay Later messaging.
///
/// The component resolves and renders the FI on the buyer's default billing agreement, exposes
/// an edit affordance that launches the PayPal paysheet via `BTPayPalClient`, and reports the
/// tokenization outcome via `completion`. The buyer's FI is resolved by the SDK from the client
/// token — the merchant supplies the checkout request plus a `PayPalSavedPaymentMethodRequest`
/// carrying the amount, currency, and merchant account the component needs.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct PayPalSavedPaymentMethodView: View {

    // MARK: - Private Properties

    @StateObject private var viewModel: PayPalSavedPaymentMethodViewModel

    /// Held on the view rather than the view model: `@StateObject` builds the view model once, so
    /// anything stored there would keep the values from the first render.
    private let payPalCheckoutRequest: BTPayPalCheckoutRequest
    private let request: PayPalSavedPaymentMethodRequest
    private let style: PayPalSavedPaymentMethodViewStyle

    // MARK: - Initializer

    /// Creates a `PayPalSavedPaymentMethodView`.
    /// - Parameters:
    ///   - authorization: Required. A client token generated with the buyer's payment method ID.
    ///     A tokenization key cannot be used — it carries no `paymentMethodIdJwt`, so the saved
    ///     funding instrument cannot be resolved.
    ///   - universalLink: Required. The URL to use for the PayPal app switch flow. Must be a valid
    ///     HTTPS URL dedicated to Braintree app switch returns, allow-listed in your Control Panel.
    ///   - payPalCheckoutRequest: Required. The PayPal checkout request used for the edit tokenization.
    ///   - request: Required. The amount, currency, and merchant account used to resolve the saved
    ///     funding instrument and its Pay Later message.
    ///   - fallbackURLScheme: Optional. A custom URL scheme to use as a fallback if the universal link fails.
    ///   - style: Optional. Styling overrides. Defaults to the shipped `PayPalSavedPaymentMethodViewStyle`.
    ///   - completion: Called with the `BTPayPalAccountNonce` (or `Error`) when the edit tokenization completes.
    public init(
        authorization: String,
        universalLink: URL,
        payPalCheckoutRequest: BTPayPalCheckoutRequest,
        request: PayPalSavedPaymentMethodRequest,
        fallbackURLScheme: String? = nil,
        style: PayPalSavedPaymentMethodViewStyle = PayPalSavedPaymentMethodViewStyle(),
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.payPalCheckoutRequest = payPalCheckoutRequest
        self.request = request
        self.style = style
        _viewModel = StateObject(
            wrappedValue: PayPalSavedPaymentMethodViewModel(
                authorization: authorization,
                universalLink: universalLink,
                fallbackURLScheme: fallbackURLScheme,
                completion: completion
            )
        )
    }

    /// Internal initializer for previews and tests — seeds a concrete render state.
    init(
        viewModel: PayPalSavedPaymentMethodViewModel,
        payPalCheckoutRequest: BTPayPalCheckoutRequest = BTPayPalCheckoutRequest(amount: "0"),
        request: PayPalSavedPaymentMethodRequest = PayPalSavedPaymentMethodRequest(amount: "0", currencyCode: "USD"),
        style: PayPalSavedPaymentMethodViewStyle = PayPalSavedPaymentMethodViewStyle()
    ) {
        self.payPalCheckoutRequest = payPalCheckoutRequest
        self.request = request
        self.style = style
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View

    public var body: some View {
        Group {
            if viewModel.fiState == .hidden {
                EmptyView()
            } else {
                container
            }
        }
        .onAppear {
            viewModel.onAppear(request: request, showCreditMessaging: style.showPayPalCreditMessaging)
        }
        .onChange(of: request) { newRequest in
            viewModel.requestChanged(newRequest, showCreditMessaging: style.showPayPalCreditMessaging)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.appReturnedToForeground()
        }
        .sheet(isPresented: $viewModel.isLanderPresented) {
            if let url = viewModel.learnMoreURL {
                PayPalCreditMessagingLanderView(url: url)
            }
        }
        .fullScreenCover(
            isPresented: editLoaderBinding,
            onDismiss: { viewModel.editLoaderDidDismiss() },
            content: {
                EditFlowLoadingView()
                    .clearPresentationBackground()
                    .onAppear { viewModel.editLoaderDidAppear() }
            }
        )
    }

    /// Read-only binding: the loader is dismissed by the view model, not by user interaction.
    private var editLoaderBinding: Binding<Bool> {
        Binding(get: { viewModel.isEditing }, set: { _ in })
    }

    private var container: some View {
        VStack(
            alignment: .leading,
            spacing: viewModel.fiState == .loading
                ? EditFIStyleDefaultConstants.loadingRowSpacing
                : EditFIStyleDefaultConstants.rowSpacing
        ) {
            fiRegion
            creditRegion
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(
            .horizontal,
            EditFIStyleGuard.dimension(
                style.container?.horizontalPadding,
                default: EditFIStyleDefaultConstants.containerHorizontalPadding
            )
        )
        .padding(
            .vertical,
            EditFIStyleGuard.dimension(
                style.container?.verticalPadding,
                default: EditFIStyleDefaultConstants.containerVerticalPadding
            )
        )
        .frame(height: EditFIStyleGuard.containerHeight(style.container?.height), alignment: .center)
        .background(Color(uiColor: EditFIStyleGuard.backgroundColor(style.componentAppearance?.backgroundColor)))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    Color(uiColor: EditFIStyleGuard.containerBorderColor(style.container?.borderColor)),
                    lineWidth: EditFIStyleGuard.dimension(
                        style.container?.borderWidth,
                        default: EditFIStyleDefaultConstants.containerBorderWidth
                    )
                )
        )
    }

    private var cornerRadius: CGFloat {
        EditFIStyleGuard.dimension(style.container?.cornerRadius, default: EditFIStyleDefaultConstants.containerCornerRadius)
    }

    @ViewBuilder private var fiRegion: some View {
        switch viewModel.fiState {
        case .loading:
            PayPalSavedPaymentMethodSkeletonRow(style: style)
        case .instrument(let summary):
            EditFIRow(content: .instrument(summary), style: style, onEdit: editTapped)
        case let .displayOnly(email, isEditable):
            EditFIRow(content: .displayOnly(email: email, isEditable: isEditable), style: style, onEdit: editTapped)
        case .brandOnly:
            EditFIRow(content: .brandOnly, style: style, onEdit: editTapped)
        case .hidden:
            EmptyView()
        }
    }

    private func editTapped() {
        viewModel.editTapped(checkoutRequest: payPalCheckoutRequest, request: request)
    }

    @ViewBuilder private var creditRegion: some View {
        if style.showPayPalCreditMessaging, viewModel.showsCreditMessaging {
            Group {
                if let content = viewModel.creditMessage {
                    CreditMessagingRow(
                        style: style,
                        message: content.message,
                        learnMoreText: content.learnMore?.text,
                        learnMoreURL: content.learnMore?.url
                    ) {
                        viewModel.learnMoreTapped()
                    }
                } else if viewModel.fiState == .loading {
                    CreditMessageSkeleton()
                }
            }
            .padding(.leading, creditLeadingInset)
        }
    }

    /// Leading inset that aligns the credit-messaging line with the "PayPal" label (i.e. past
    /// the logo). Zero when the logo is hidden and the label already starts at the leading edge.
    private var creditLeadingInset: CGFloat {
        guard style.showPayPalLogo else { return 0 }
        let logoSide = EditFIStyleGuard.dimension(
            style.container?.logo?.width,
            default: EditFIStyleDefaultConstants.payPalLogoSide
        )
        let labelGap = EditFIStyleGuard.dimension(
            style.container?.label?.leadingGap,
            default: EditFIStyleDefaultConstants.labelLeadingGap
        )
        return logoSide + labelGap
    }
}

// MARK: - Edit-flow loader

/// Full-screen loader shown while the edit paysheet (create-payment-resource) is being prepared.
private struct EditFlowLoadingView: View {

    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            Color.white.opacity(EditFIStyleDefaultConstants.editLoaderOverlayOpacity).ignoresSafeArea()
            Image("LoadingSpinner", bundle: .payPalSavedPaymentMethod)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(
                    width: EditFIStyleDefaultConstants.editLoaderSpinnerSide,
                    height: EditFIStyleDefaultConstants.editLoaderSpinnerSide
                )
                .foregroundColor(.black)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

private extension View {

    /// Makes a `fullScreenCover` background see-through (iOS 16.4+) so the merchant's screen shows
    /// faintly behind the loader; a no-op on earlier versions (opaque backdrop).
    @ViewBuilder func clearPresentationBackground() -> some View {
        if #available(iOS 16.4, *) {
            presentationBackground(.clear)
        } else {
            self
        }
    }
}

// MARK: - Previews

struct PayPalSavedPaymentMethodView_Previews: PreviewProvider {

    private static func preview(
        _ title: String,
        _ state: PayPalSavedPaymentMethodViewModel.FIState,
        style: PayPalSavedPaymentMethodViewStyle = PayPalSavedPaymentMethodViewStyle()
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            PayPalSavedPaymentMethodView(
                viewModel: PayPalSavedPaymentMethodViewModel(previewState: state),
                style: style
            )
            .border(Color.gray.opacity(0.2))
        }
    }

    /// Builds a data-layer instrument for previews, which only has a failable JSON initializer.
    private static func previewInstrument(
        type: String,
        label: String,
        lastDigits: String,
        imageURL: String? = nil
    ) -> PayPalSavedPaymentMethod {
        var json: [String: Any] = ["type": type, "label": label, "lastDigits": lastDigits]
        if let imageURL {
            json["imageUrl"] = imageURL
        }
        // Force-unwrapped: the literal above is always a valid object.
        // swiftlint:disable:next force_unwrapping
        return PayPalSavedPaymentMethod(json: BTJSON(value: json))!
    }

    private static var borderedStyle: PayPalSavedPaymentMethodViewStyle {
        PayPalSavedPaymentMethodViewStyle(
            container: .init(horizontalPadding: 12, cornerRadius: 8, borderColor: .systemGray4, borderWidth: 1)
        )
    }

    static var previews: some View {
        let cardWithArt = previewInstrument(
            type: "CARD",
            label: "Visa",
            lastDigits: "0199",
            imageURL: "https://www.paypalobjects.com/visa.png"
        )
        let bank = previewInstrument(type: "BANK", label: "CREDIT UNION 1", lastDigits: "3357")
        let longLabel = previewInstrument(
            type: "CARD",
            label: "A Very Long Funding Instrument Bank Name",
            lastDigits: "1234"
        )
        let mastercard = previewInstrument(type: "CARD", label: "Mastercard", lastDigits: "4444")

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                preview("Loading (skeleton)", .loading)
                preview("Instrument — card with art", .instrument(cardWithArt))
                preview("Instrument — no image (fallback glyph)", .instrument(bank))
                preview("Instrument — truncation", .instrument(longLabel))
                preview("Display-only (email)", .displayOnly(email: "buyer@example.com", isEditable: true))
                preview("Brand only (no network)", .brandOnly)
                preview("Bordered container", .instrument(mastercard), style: borderedStyle)
            }
            .padding()
        }
    }
}
