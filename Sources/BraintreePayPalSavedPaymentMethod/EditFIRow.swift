import SwiftUI
import UIKit

/// The funding-instrument chip: `[badge] PayPal  [ card-art •• 1234  ✎ ]`.
///
/// The brand mark (badge + "PayPal") sits on the left; the FI (card art + last digits + edit
/// pencil) sits in a rounded pill to its right. Renders three variants:
/// - `.instrument` — the art PayPal returns, then `••1234` for a regular card or bank account and
///   the label for anything else (PayPal Credit, PayPal balance, Pay in 4, ...), plus the edit pencil
/// - `.displayOnly` — buyer email + edit pencil (no-FI-but-email fallback)
/// - `.brandOnly` — PayPal brand mark only, when there is no FI or email to show
struct EditFIRow: View {

    enum Content: Equatable {
        case instrument(PayPalSavedPaymentMethod)
        case displayOnly(email: String, isEditable: Bool)
        case brandOnly
    }

    let content: Content
    let style: PayPalSavedPaymentMethodViewStyle
    let onEdit: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Private Properties

    /// Fixed rather than the merchant's text color, so it stays legible on the fixed pill background.
    private var pillContentColor: Color {
        Color(uiColor: EditFIStyleDefaultConstants.fundingInstrumentTextColor)
    }

    private var fiFont: Font {
        PayPalSavedPaymentMethodFont.font(
            size: EditFIStyleGuard.fontSize(
                style.container?.fundingInstrument?.textFontSize,
                base: style.componentAppearance?.baseFontSize,
                default: EditFIStyleDefaultConstants.fundingInstrumentTextFontSize
            ),
            dynamicTypeSize: dynamicTypeSize,
            name: style.componentAppearance?.fontName
        )
    }

    private var editIconSide: CGFloat {
        EditFIStyleGuard.dimension(
            style.container?.fundingInstrument?.editIconSize,
            default: EditFIStyleDefaultConstants.editIconSize
        )
    }

    private var fundingInstrumentGap: CGFloat {
        EditFIStyleGuard.dimension(
            style.container?.fundingInstrument?.leadingGap,
            default: EditFIStyleDefaultConstants.fundingInstrumentLeadingGap
        )
    }

    // MARK: - Body

    var body: some View {
        // At large accessibility text sizes the brand mark and the pill no longer fit side by side;
        // stacking keeps the funding instrument legible instead of truncating it.
        ViewThatFits(in: .horizontal) {
            sideBySideLayout
            stackedLayout
        }
    }

    // MARK: - Layouts

    private var sideBySideLayout: some View {
        HStack(spacing: 0) {
            if showsBrandMark {
                brandCluster
            }
            fiCluster
                .padding(.leading, showsBrandMark ? fundingInstrumentGap : 0)

            // Keep the cluster left-aligned; the pill hugs the brand mark.
            Spacer(minLength: 0)
        }
    }

    private var stackedLayout: some View {
        // Rows with nothing to draw are left out so the stack doesn't add spacing around them.
        VStack(alignment: .leading, spacing: EditFIStyleDefaultConstants.stackedLayoutSpacing) {
            if showsBrandMark {
                HStack(spacing: 0) {
                    brandCluster
                    Spacer(minLength: 0)
                }
            }
            if content != .brandOnly {
                HStack(spacing: 0) {
                    fiCluster
                    Spacer(minLength: 0)
                }
            }
        }
    }

    @ViewBuilder private var fiCluster: some View {
        switch content {
        case .instrument(let summary):
            editable(label: fiAccessibilityLabel(for: summary)) {
                fiPill {
                    HStack(spacing: EditFIStyleDefaultConstants.fundingInstrumentViewEditSpacing) {
                        HStack(spacing: EditFIStyleDefaultConstants.fundingInstrumentViewGroupSpacing) {
                            if summary.imageURL != nil || fallbackGlyphName(for: summary) != nil {
                                fiIcon(for: summary)
                            }
                            Text(fiText(for: summary))
                                .font(fiFont)
                                .foregroundColor(pillContentColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        editGlyph
                    }
                }
            }
        case let .displayOnly(email, isEditable):
            let pill = fiPill {
                HStack(spacing: EditFIStyleDefaultConstants.fundingInstrumentViewEditSpacing) {
                    Text(email)
                        .font(fiFont)
                        .foregroundColor(pillContentColor)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    if isEditable {
                        editGlyph
                    }
                }
            }

            if isEditable {
                editable(label: email) { pill }
            } else {
                pill
            }
        case .brandOnly:
            EmptyView()
        }
    }

    /// The whole pill is the tap target, not just the pencil: a 20pt glyph is well under the 44pt
    /// minimum and is the only affordance the buyer has to change what will be charged.
    private func editable(label: String, @ViewBuilder _ content: () -> some View) -> some View {
        Button(action: onEdit) {
            content()
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Change payment method")
    }

    /// Names PayPal when the brand mark is hidden, and never reads an empty label. Internal for testing.
    func fiAccessibilityLabel(for summary: PayPalSavedPaymentMethod) -> String {
        let label = summary.label.flatMap { $0.isEmpty ? nil : $0 }
        var parts = showsBrandMark ? [] : ["PayPal"]

        if showsLastDigits(summary), let lastDigits = summary.lastDigits {
            // Spaced so VoiceOver reads each digit instead of one number.
            let spokenDigits = lastDigits.map(String.init).joined(separator: " ")
            parts += [label, "ending in \(spokenDigits)"].compactMap { $0 }
        } else {
            parts.append(label ?? "Saved payment method")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - Subviews

    private var brandCluster: some View {
        PayPalBrandCluster(style: style)
    }

    /// The rounded pill wrapping the FI content + edit pencil. Fixed values — not merchant-configurable.
    private func fiPill<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, EditFIStyleDefaultConstants.fundingInstrumentHorizontalPadding)
            .padding(.vertical, EditFIStyleDefaultConstants.fundingInstrumentVerticalPadding)
            .background(pillBackground)
    }

    private var pillBackground: some View {
        RoundedRectangle(cornerRadius: EditFIStyleDefaultConstants.fundingInstrumentCornerRadius)
            .fill(Color(uiColor: EditFIStyleDefaultConstants.fundingInstrumentBackgroundColor))
    }

    /// The FI art. While it loads the frame stays blank so the glyph doesn't flash before the art arrives.
    @ViewBuilder private func fiIcon(for summary: PayPalSavedPaymentMethod) -> some View {
        if let url = summary.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    framedIcon(image.resizable().scaledToFit())
                case .empty:
                    framedIcon(Color.clear)
                default:
                    fallbackGlyph(for: summary)
                }
            }
        } else {
            fallbackGlyph(for: summary)
        }
    }

    private func framedIcon(_ content: some View) -> some View {
        content
            .frame(
                width: EditFIStyleDefaultConstants.cardArtWidth,
                height: EditFIStyleDefaultConstants.cardArtHeight
            )
            .clipShape(RoundedRectangle(cornerRadius: cardIconRadius))
            .overlay(cardIconBorder)
            .accessibilityHidden(true)
    }

    private var cardIconRadius: CGFloat {
        EditFIStyleDefaultConstants.cardIconCornerRadius
    }

    private var cardIconBorder: some View {
        RoundedRectangle(cornerRadius: cardIconRadius)
            .strokeBorder(
                Color(uiColor: EditFIStyleDefaultConstants.cardIconBorderColor),
                lineWidth: EditFIStyleDefaultConstants.cardIconBorderWidth
            )
    }

    /// Nothing for a PayPal product, whose label already identifies it.
    @ViewBuilder private func fallbackGlyph(for summary: PayPalSavedPaymentMethod) -> some View {
        if let name = fallbackGlyphName(for: summary) {
            framedIcon(Image(name, bundle: .payPalSavedPaymentMethod).resizable().scaledToFit())
        }
    }

    /// Decorative: the surrounding pill carries the tap and the accessibility traits.
    private var editGlyph: some View {
        Image("EditPencil", bundle: .payPalSavedPaymentMethod)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: editIconSide, height: editIconSide)
            .foregroundColor(pillContentColor)
            .accessibilityHidden(true)
    }

    // MARK: - Helpers

    /// The merchant may hide both the logo and the label.
    private var showsBrandMark: Bool {
        style.showPayPalLogo || style.showPayPalLabel
    }

    /// `••1234` is only meaningful for a regular card or bank account. PayPal products (PayPal Credit,
    /// PayPal Debit, PayPal balance, Pay in 4, ...) carry a `subtype` or another type and are shown by
    /// their label, so new products need no SDK change.
    private func showsLastDigits(_ summary: PayPalSavedPaymentMethod) -> Bool {
        guard summary.type == .card || summary.type == .bank, summary.subtype == nil else {
            return false
        }
        return !(summary.lastDigits ?? "").isEmpty
    }

    /// The text shown in the pill. Internal for testing.
    func fiText(for summary: PayPalSavedPaymentMethod) -> String {
        guard showsLastDigits(summary), let lastDigits = summary.lastDigits else {
            return summary.label ?? ""
        }
        // Card art conveys the brand; the text is just the masked last digits.
        return "••\(lastDigits)"
    }

    /// The bundled glyph shown when a regular card or bank has no art, or its art fails to load.
    /// PayPal products without art show their label alone. Internal for testing.
    func fallbackGlyphName(for summary: PayPalSavedPaymentMethod) -> String? {
        guard showsLastDigits(summary) else {
            return nil
        }
        return summary.type == .bank ? "BankFundingIcon" : "CardFundingIcon"
    }
}
