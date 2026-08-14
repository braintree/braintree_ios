import BraintreeCore
import BraintreePayPal
import SwiftUI
import UIKit

/// A drop-in checkout component that shows the returning PayPal buyer's saved funding
/// instrument (FI) and lets them edit it, with optional inline Pay Later messaging.
///
/// The component resolves and renders the sticky FI, exposes an edit affordance that
/// launches the PayPal paysheet, and reports the outcome via `onResult`. The buyer's FI is
/// resolved by the SDK from the client token — the merchant supplies only the checkout
/// request (its amount also drives the credit-messaging line).
///
/// > Note: The fetch/edit network calls are not yet wired in; the component renders its
/// > loading and result states from the view model, which is where those APIs plug in.
public struct BTPayPalSavedPaymentMethodView: View {

    // MARK: - Private Properties

    @StateObject private var viewModel: BTPayPalSavedPaymentMethodViewModel

    private var style: BTPayPalSavedPaymentMethodViewStyle { viewModel.style }

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodView`.
    /// - Parameters:
    ///   - authorization: Required. A valid client token or tokenization key. The saved FI is
    ///     resolved from the client token.
    ///   - request: Required. The request configuring the component (checkout request + credit-message toggle).
    ///   - style: Optional. Styling overrides. Defaults to the shipped `BTPayPalSavedPaymentMethodViewStyle`.
    ///   - onResult: Called with the terminal `BTPayPalSavedPaymentMethodResult` after an edit flow completes.
    public init(
        authorization: String,
        request: BTPayPalSavedPaymentMethodRequest,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle(),
        onResult: @escaping (BTPayPalSavedPaymentMethodResult) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: BTPayPalSavedPaymentMethodViewModel(
                request: request,
                style: style,
                onResult: onResult,
                apiClient: BTAPIClient(authorization: authorization)
            )
        )
    }

    /// Internal initializer for previews and tests — seeds a concrete render state.
    init(viewModel: BTPayPalSavedPaymentMethodViewModel) {
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
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $viewModel.isLanderPresented) {
            CreditMessagingLanderView(url: viewModel.learnMoreURL)
        }
    }

    private var container: some View {
        // Tighter row gap while loading (skeleton) than in the loaded state.
        VStack(alignment: .leading, spacing: viewModel.fiState == .loading ? 4 : 6) {
            fiRegion
            creditRegion
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: style.container.height, alignment: .center)
        .padding(.horizontal, EditFiStyleGuard.horizontalPadding(style.container.horizontalPadding))
        .padding(.vertical, EditFiStyleGuard.verticalPadding(style.container.verticalPadding))
        .background(Color(uiColor: style.theme.backgroundColor ?? .clear))
        .clipShape(RoundedRectangle(cornerRadius: EditFiStyleGuard.cornerRadius(style.container.cornerRadius)))
        .overlay(
            RoundedRectangle(cornerRadius: EditFiStyleGuard.cornerRadius(style.container.cornerRadius))
                .stroke(
                    Color(uiColor: style.container.borderColor ?? .clear),
                    lineWidth: EditFiStyleGuard.borderWidth(style.container.borderWidth)
                )
        )
    }

    @ViewBuilder private var fiRegion: some View {
        switch viewModel.fiState {
        case .loading:
            BTPayPalSavedPaymentMethodSkeletonRow(style: style)
        case .instrument(let summary):
            EditFIRow(content: .instrument(summary), style: style) { viewModel.editTapped() }
        case .displayOnly(let email):
            EditFIRow(content: .displayOnly(email: email), style: style) { viewModel.editTapped() }
        case .brandOnly:
            EditFIRow(content: .brandOnly, style: style) { viewModel.editTapped() }
        case .hidden:
            EmptyView()
        }
    }

    @ViewBuilder private var creditRegion: some View {
        if viewModel.request.showCreditMessage, style.showCreditMessaging {
            Group {
                if viewModel.fiState == .loading {
                    CreditMessageSkeleton()
                } else {
                    CreditMessagingRow(style: style) {
                        viewModel.learnMoreTapped()
                    }
                }
            }
            .padding(.leading, creditLeadingInset)
        }
    }

    /// Leading inset that aligns the credit-messaging line with the "PayPal" label (i.e. past
    /// the logo). Zero when the logo is hidden and the label already starts at the leading edge.
    private var creditLeadingInset: CGFloat {
        guard style.showLogo else { return 0 }
        let logoSide = style.container.logo.width.map { EditFiStyleGuard.logoWidth($0) } ?? PayPalBrandCluster.defaultLogoSide
        return logoSide + EditFiStyleGuard.labelLeadingGap(style.container.label.leadingGap)
    }
}

// MARK: - Preview / Demo support

/// Render-state selector for the demo/preview initializer below.
///
/// - Note: This is a temporary seam for demos, SwiftUI previews, and UI tests while the
///   fetch API is not yet wired. It is expected to be removed once `BTPayPalSavedPaymentMethodView`
///   resolves its own state from the network.
public enum BTPayPalSavedPaymentMethodPreviewState: Equatable {
    case loading
    case instrument(BTPayPalSavedPaymentMethodFISummary)
    case displayOnly(email: String)
    case brandOnly
    case hidden
}

extension BTPayPalSavedPaymentMethodView {

    /// Seeds a concrete render state, bypassing the fetch API (not yet wired). Intended for
    /// demos, SwiftUI previews, and UI tests only.
    ///
    /// - Note: Temporary — remove once the component resolves its state from the network.
    public init(
        previewState: BTPayPalSavedPaymentMethodPreviewState,
        showCreditMessage: Bool = false,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
    ) {
        let request = BTPayPalSavedPaymentMethodRequest(
            payPalRequest: BTPayPalCheckoutRequest(amount: "0"),
            showCreditMessage: showCreditMessage
        )
        let fiState: BTPayPalSavedPaymentMethodViewModel.FIState
        switch previewState {
        case .loading:
            fiState = .loading
        case .instrument(let summary):
            fiState = .instrument(summary)
        case .displayOnly(let email):
            fiState = .displayOnly(email: email)
        case .brandOnly:
            fiState = .brandOnly
        case .hidden:
            fiState = .hidden
        }
        self.init(viewModel: BTPayPalSavedPaymentMethodViewModel(previewState: fiState, request: request, style: style))
    }
}

// MARK: - Previews

struct BTPayPalSavedPaymentMethodView_Previews: PreviewProvider {

    private static let request = BTPayPalSavedPaymentMethodRequest(
        payPalRequest: BTPayPalCheckoutRequest(amount: "324.50"),
        showCreditMessage: true
    )

    private static func preview(
        _ title: String,
        _ state: BTPayPalSavedPaymentMethodViewModel.FIState,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            BTPayPalSavedPaymentMethodView(
                viewModel: BTPayPalSavedPaymentMethodViewModel(previewState: state, request: request, style: style)
            )
            .border(Color.gray.opacity(0.2))
        }
    }

    private static var borderedStyle: BTPayPalSavedPaymentMethodViewStyle {
        var style = BTPayPalSavedPaymentMethodViewStyle()
        style.container.cornerRadius = 8
        style.container.borderColor = .systemGray4
        style.container.borderWidth = 1
        style.container.horizontalPadding = 12
        return style
    }

    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                preview("Loading (skeleton)", .loading)
                preview("Instrument — card with art", .instrument(
                    BTPayPalSavedPaymentMethodFISummary(type: "CARD", label: "Visa", lastDigits: "0199",
                              imageURL: URL(string: "https://www.paypalobjects.com/visa.png"))
                ))
                preview("Instrument — no image (fallback glyph)", .instrument(
                    BTPayPalSavedPaymentMethodFISummary(type: "BANK", label: "CREDIT UNION 1", lastDigits: "3357")
                ))
                preview("Instrument — truncation", .instrument(
                    BTPayPalSavedPaymentMethodFISummary(type: "CARD", label: "A Very Long Funding Instrument Bank Name", lastDigits: "1234")
                ))
                preview("Display-only (email)", .displayOnly(email: "buyer@example.com"))
                preview("Brand only (no network)", .brandOnly)
                preview("Bordered container", .instrument(
                    BTPayPalSavedPaymentMethodFISummary(type: "CARD", label: "Mastercard", lastDigits: "4444")
                ), style: borderedStyle)
            }
            .padding()
        }
    }
}
