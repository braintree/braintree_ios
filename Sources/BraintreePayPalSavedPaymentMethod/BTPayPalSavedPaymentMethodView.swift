import BraintreeCore
import BraintreePayPal
import SwiftUI

/// A drop-in checkout component that shows the returning PayPal buyer's saved funding
/// instrument (FI) and lets them edit it, with optional inline Pay Later messaging.
///
/// The component resolves and renders the sticky FI, exposes an edit affordance that
/// launches the PayPal paysheet via `BTPayPalClient`, and reports the tokenization outcome
/// via `completion`. The buyer's FI is resolved by the SDK from the client token — the
/// merchant supplies the checkout request plus a `BTPayPalSavedPaymentMethodRequest` carrying
/// the amount, currency, and merchant account the component needs.
public struct BTPayPalSavedPaymentMethodView: View {

    // MARK: - Private Properties

    @StateObject private var viewModel: BTPayPalSavedPaymentMethodViewModel

    /// Held on the view rather than the view model: `@StateObject` builds the view model once, so
    /// anything stored there would keep the values from the first render.
    private let payPalCheckoutRequest: BTPayPalCheckoutRequest
    private let request: BTPayPalSavedPaymentMethodRequest
    private let style: BTPayPalSavedPaymentMethodViewStyle

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodView`.
    /// - Parameters:
    ///   - payPalCheckoutRequest: Required. The PayPal checkout request used for the edit tokenization.
    ///   - request: Required. The amount, currency, and merchant account used to resolve the saved
    ///     funding instrument and its Pay Later message.
    ///   - authorization: Required. A client token generated with the buyer's payment method ID.
    ///     A tokenization key cannot be used — it carries no `paymentMethodIdJwt`, so the saved
    ///     funding instrument cannot be resolved.
    ///   - universalLink: Required. The URL to use for the PayPal app switch flow. Must be a valid
    ///     HTTPS URL dedicated to Braintree app switch returns, allow-listed in your Control Panel.
    ///   - fallbackURLScheme: Optional. A custom URL scheme to use as a fallback if the universal link fails.
    ///   - style: Optional. Styling overrides. Defaults to the shipped `BTPayPalSavedPaymentMethodViewStyle`.
    ///   - completion: Called with the `BTPayPalAccountNonce` (or `Error`) when the edit tokenization completes.
    public init(
        payPalCheckoutRequest: BTPayPalCheckoutRequest,
        request: BTPayPalSavedPaymentMethodRequest,
        authorization: String,
        universalLink: URL,
        fallbackURLScheme: String? = nil,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle(),
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.payPalCheckoutRequest = payPalCheckoutRequest
        self.request = request
        self.style = style
        _viewModel = StateObject(
            wrappedValue: BTPayPalSavedPaymentMethodViewModel(
                universalLink: universalLink,
                fallbackURLScheme: fallbackURLScheme,
                completion: completion,
                authorization: authorization
            )
        )
    }

    /// Internal initializer for previews and tests — seeds a concrete render state.
    init(
        viewModel: BTPayPalSavedPaymentMethodViewModel,
        payPalCheckoutRequest: BTPayPalCheckoutRequest = BTPayPalCheckoutRequest(amount: "0"),
        request: BTPayPalSavedPaymentMethodRequest = BTPayPalSavedPaymentMethodRequest(amount: "0", currencyCode: "USD"),
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
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
                BTPayPalCreditMessagingLanderView(url: url)
            }
        }
        .fullScreenCover(isPresented: editLoaderBinding) {
            EditFlowLoadingView()
                .clearPresentationBackground()
        }
    }

    /// Read-only binding: the loader is dismissed by the view model, not by user interaction.
    private var editLoaderBinding: Binding<Bool> {
        Binding(get: { viewModel.isEditing }, set: { _ in })
    }

    private var container: some View {
        // Tighter row gap while loading (skeleton) than in the loaded state.
        VStack(alignment: .leading, spacing: viewModel.fiState == .loading ? 4 : 6) {
            fiRegion
            creditRegion
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, EditFiStyleGuard.horizontalPadding(style.container?.horizontalPadding))
        .padding(.vertical, EditFiStyleGuard.verticalPadding(style.container?.verticalPadding))
        .frame(height: style.container?.height, alignment: .center)
        .background(Color(uiColor: EditFiStyleGuard.backgroundColor(style.componentAppearance?.backgroundColor)))
        .clipShape(RoundedRectangle(cornerRadius: EditFiStyleGuard.cornerRadius(style.container?.cornerRadius)))
        .overlay(
            RoundedRectangle(cornerRadius: EditFiStyleGuard.cornerRadius(style.container?.cornerRadius))
                .stroke(
                    Color(uiColor: EditFiStyleGuard.containerBorderColor(style.container?.borderColor)),
                    lineWidth: EditFiStyleGuard.borderWidth(style.container?.borderWidth)
                )
        )
    }

    @ViewBuilder private var fiRegion: some View {
        switch viewModel.fiState {
        case .loading:
            BTPayPalSavedPaymentMethodSkeletonRow(style: style)
        case .instrument(let summary):
            EditFIRow(content: .instrument(summary), style: style, onEdit: editTapped)
        case .displayOnly(let email, let isEditable):
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
        if style.showPayPalCreditMessaging, !viewModel.didCompleteEdit {
            Group {
                // Keep an already-resolved message on screen while the FI refreshes after an edit.
                if let content = viewModel.creditMessage {
                    CreditMessagingRow(style: style, content: content) {
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
        let logoSide = style.container?.logo?.width.map { EditFiStyleGuard.logoWidth($0) } ?? EditFiStyleGuard.Defaults.payPalLogoSide
        return logoSide + EditFiStyleGuard.labelLeadingGap(style.container?.label?.leadingGap)
    }
}

// MARK: - Edit-flow loader

/// Full-screen loader shown while the edit paysheet (create-payment-resource) is being prepared.
private struct EditFlowLoadingView: View {

    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            Image("LoadingSpinner", bundle: .payPalSavedPaymentMethod)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
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

    /// Makes a `fullScreenCover` background see-through (iOS 16.4+) so the merchant's screen dims
    /// behind the loader; a no-op on earlier versions (opaque backdrop).
    @ViewBuilder func clearPresentationBackground() -> some View {
        if #available(iOS 16.4, *) {
            presentationBackground(.clear)
        } else {
            self
        }
    }
}

// MARK: - Previews

struct BTPayPalSavedPaymentMethodView_Previews: PreviewProvider {

    private static func preview(
        _ title: String,
        _ state: BTPayPalSavedPaymentMethodViewModel.FIState,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            BTPayPalSavedPaymentMethodView(
                viewModel: BTPayPalSavedPaymentMethodViewModel(previewState: state),
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
    ) -> BTPayPalSavedPaymentMethod {
        var json: [String: Any] = ["type": type, "label": label, "lastDigits": lastDigits]
        if let imageURL {
            json["imageUrl"] = imageURL
        }
        // Force-unwrapped: the literal above is always a valid object.
        return BTPayPalSavedPaymentMethod(json: BTJSON(value: json))!
    }

    private static var borderedStyle: BTPayPalSavedPaymentMethodViewStyle {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        var container = BTPayPalSavedPaymentMethodViewStyle.ContainerStyle()
        container.cornerRadius = 8
        container.borderColor = .systemGray4
        container.borderWidth = 1
        container.horizontalPadding = 12
        style.container = container
        return style
    }

    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                preview("Loading (skeleton)", .loading)
                preview("Instrument — card with art", .instrument(
                    previewInstrument(type: "CARD", label: "Visa", lastDigits: "0199", imageURL: "https://www.paypalobjects.com/visa.png")
                ))
                preview("Instrument — no image (fallback glyph)", .instrument(
                    previewInstrument(type: "BANK", label: "CREDIT UNION 1", lastDigits: "3357")
                ))
                preview("Instrument — truncation", .instrument(
                    previewInstrument(type: "CARD", label: "A Very Long Funding Instrument Bank Name", lastDigits: "1234")
                ))
                preview("Display-only (email)", .displayOnly(email: "buyer@example.com", isEditable: true))
                preview("Brand only (no network)", .brandOnly)
                preview("Bordered container", .instrument(
                    previewInstrument(type: "CARD", label: "Mastercard", lastDigits: "4444")
                ), style: borderedStyle)
            }
            .padding()
        }
    }
}
