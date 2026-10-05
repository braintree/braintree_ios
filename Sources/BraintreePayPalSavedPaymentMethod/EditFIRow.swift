import SwiftUI
import UIKit

/// The funding-instrument chip: `[badge] PayPal  [ card-art •• 1234  ✎ ]`.
///
/// The brand mark (badge + "PayPal") sits on the left; the FI (card art + last digits + edit
/// pencil) sits in a rounded pill to its right. Renders three variants:
/// - `.instrument` — card art (or generic fallback glyph) + last digits + edit pencil, except for
///   PayPal Credit, which renders its label alone
/// - `.displayOnly` — buyer email + edit pencil (no-FI-but-email fallback)
/// - `.brandOnly` — PayPal brand mark only (no-network fallback)
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

    // MARK: - Derived style values (guarded)

    private var textColor: Color {
        Color(uiColor: EditFIStyleGuard.textColor(style.componentAppearance?.textColor))
    }

    private var fiFont: Font {
        PayPalSavedPaymentMethodFont.font(
            size: EditFIStyleGuard.fontSize(
                style.container?.fundingInstrument?.textFontSize,
                base: style.componentAppearance?.baseFontSize,
                default: EditFIStyleGuard.Defaults.fundingInstrumentTextFontSize
            ),
            dynamicTypeSize: dynamicTypeSize,
            name: style.componentAppearance?.fontName
        )
    }

    private var editIconSide: CGFloat {
        EditFIStyleGuard.dimension(
            style.container?.fundingInstrument?.editIconSize,
            default: EditFIStyleGuard.Defaults.editIconSize
        )
    }

    private var fundingInstrumentGap: CGFloat {
        EditFIStyleGuard.dimension(
            style.container?.fundingInstrument?.leadingGap,
            default: EditFIStyleGuard.Defaults.fundingInstrumentLeadingGap
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
            brandCluster
            fiCluster
                .padding(.leading, fundingInstrumentGap)

            // Keep the cluster left-aligned; the pill hugs the brand mark.
            Spacer(minLength: 0)
        }
    }

    private var stackedLayout: some View {
        VStack(alignment: .leading, spacing: EditFIStyleGuard.Defaults.stackedLayoutSpacing) {
            HStack(spacing: 0) {
                brandCluster
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                fiCluster
                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder private var fiCluster: some View {
        switch content {
        case .instrument(let summary):
            editable(label: fiAccessibilityLabel(for: summary)) {
                fiPill {
                    HStack(spacing: EditFIStyleGuard.Defaults.fundingInstrumentViewEditSpacing) {
                        HStack(spacing: EditFIStyleGuard.Defaults.fundingInstrumentViewGroupSpacing) {
                            if !isPayPalCredit(summary) {
                                fiIcon(for: summary)
                            }
                            Text(fiText(for: summary))
                                .font(fiFont)
                                .foregroundColor(textColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        editGlyph
                    }
                }
            }
        case let .displayOnly(email, isEditable):
            let pill = fiPill {
                HStack(spacing: EditFIStyleGuard.Defaults.fundingInstrumentViewEditSpacing) {
                    Text(email)
                        .font(fiFont)
                        .foregroundColor(textColor)
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
        .accessibilityHint("Change the funding instrument PayPal will charge")
    }

    private func fiAccessibilityLabel(for summary: PayPalSavedPaymentMethod) -> String {
        if isPayPalCredit(summary) {
            return summary.label ?? ""
        }

        guard let lastDigits = summary.lastDigits, !lastDigits.isEmpty else {
            return summary.label ?? ""
        }
        return [summary.label, "ending in \(lastDigits)"].compactMap { $0 }.joined(separator: ", ")
    }

    // MARK: - Subviews

    private var brandCluster: some View {
        PayPalBrandCluster(style: style)
    }

    /// The rounded pill wrapping the FI content + edit pencil. Fixed to the Figma values — not
    /// merchant-configurable.
    private func fiPill<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, EditFIStyleGuard.Defaults.fundingInstrumentHorizontalPadding)
            .padding(.vertical, EditFIStyleGuard.Defaults.fundingInstrumentVerticalPadding)
            .background(pillBackground)
    }

    private var pillBackground: some View {
        RoundedRectangle(cornerRadius: EditFIStyleGuard.Defaults.fundingInstrumentCornerRadius)
            .fill(Color(uiColor: EditFIStyleGuard.Defaults.fundingInstrumentBackgroundColor))
    }

    @ViewBuilder private func fiIcon(for summary: PayPalSavedPaymentMethod) -> some View {
        Group {
            if let url = summary.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .empty:
                        // In flight — stay blank so the glyph doesn't flash before the art arrives.
                        Color.clear
                    default:
                        fallbackGlyph(for: summary.type)
                    }
                }
            } else {
                fallbackGlyph(for: summary.type)
            }
        }
        .frame(
            width: EditFIStyleGuard.Defaults.cardArtWidth,
            height: EditFIStyleGuard.Defaults.cardArtHeight
        )
        .clipShape(RoundedRectangle(cornerRadius: cardIconRadius))
        .overlay(cardIconBorder)
        .accessibilityHidden(true)
    }

    private var cardIconRadius: CGFloat {
        EditFIStyleGuard.Defaults.cardIconCornerRadius
    }

    private var cardIconBorder: some View {
        RoundedRectangle(cornerRadius: cardIconRadius)
            .strokeBorder(
                Color(uiColor: EditFIStyleGuard.Defaults.cardIconBorderColor),
                lineWidth: EditFIStyleGuard.Defaults.cardIconBorderWidth
            )
    }

    /// Shown when the card art is missing or fails to load. Only banks get the bank glyph;
    /// every other instrument falls back to the card glyph.
    private func fallbackGlyph(for type: PayPalSavedPaymentMethodType?) -> some View {
        Image(type == .bank ? "BankFundingIcon" : "CardFundingIcon", bundle: .payPalSavedPaymentMethod)
            .resizable()
            .scaledToFit()
    }

    /// Decorative: the surrounding pill carries the tap and the accessibility traits.
    private var editGlyph: some View {
        Image("EditPencil", bundle: .payPalSavedPaymentMethod)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: editIconSide, height: editIconSide)
            .foregroundColor(textColor)
            .accessibilityHidden(true)
    }

    // MARK: - Helpers

    /// PayPal Credit isn't a card, so it's shown by its label rather than card art and last digits.
    private func isPayPalCredit(_ summary: PayPalSavedPaymentMethod) -> Bool {
        summary.type == .payPalCredit
    }

    private func fiText(for summary: PayPalSavedPaymentMethod) -> String {
        if isPayPalCredit(summary) {
            return summary.label ?? ""
        }

        guard let lastDigits = summary.lastDigits, !lastDigits.isEmpty else {
            return summary.label ?? ""
        }
        // Card art conveys the brand; the text is just the masked last digits.
        return "••\(lastDigits)"
    }
}

/// The PayPal brand mark: `[badge] PayPal`. Shared by the loaded row and the loading skeleton
/// so the brand stays visible while the FI loads.
struct PayPalBrandCluster: View {

    let style: PayPalSavedPaymentMethodViewStyle

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var textColor: Color {
        Color(uiColor: EditFIStyleGuard.textColor(style.componentAppearance?.textColor))
    }

    private var labelFont: Font {
        PayPalSavedPaymentMethodFont.font(
            size: EditFIStyleGuard.fontSize(
                style.container?.label?.fontSize,
                base: style.componentAppearance?.baseFontSize,
                default: EditFIStyleGuard.Defaults.labelFontSize
            ),
            dynamicTypeSize: dynamicTypeSize,
            name: style.componentAppearance?.fontName,
            weight: .bold
        )
    }

    /// The PayPal logo (48×30 artwork) sits in a square (1:1) container. `logo.width` sets the
    /// side (default 48); the artwork scales to fit inside, preserving its own aspect ratio.
    private var logoSide: CGFloat {
        EditFIStyleGuard.dimension(style.container?.logo?.width, default: EditFIStyleGuard.Defaults.payPalLogoSide)
    }

    var body: some View {
        HStack(spacing: EditFIStyleGuard.dimension(
            style.container?.label?.leadingGap,
            default: EditFIStyleGuard.Defaults.labelLeadingGap
        )) {
            if style.showPayPalLogo {
                Image("PayPalBadge", bundle: .payPalSavedPaymentMethod)
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSide, height: logoSide)
                    .accessibilityHidden(true)
            }
            if style.showPayPalLabel {
                Text("PayPal")
                    .font(labelFont)
                    .foregroundColor(textColor)
                    .fixedSize()
            }
        }
    }
}
