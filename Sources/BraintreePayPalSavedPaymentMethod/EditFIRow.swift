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
            brandCluster
            fiCluster
                .padding(.leading, fundingInstrumentGap)

            // Keep the cluster left-aligned; the pill hugs the brand mark.
            Spacer(minLength: 0)
        }
    }

    private var stackedLayout: some View {
        VStack(alignment: .leading, spacing: EditFIStyleDefaultConstants.stackedLayoutSpacing) {
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
                    HStack(spacing: EditFIStyleDefaultConstants.fundingInstrumentViewEditSpacing) {
                        HStack(spacing: EditFIStyleDefaultConstants.fundingInstrumentViewGroupSpacing) {
                            if !isPayPalCredit(summary) {
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

    private func fiAccessibilityLabel(for summary: PayPalSavedPaymentMethod) -> String {
        guard let lastDigits = lastDigits(for: summary) else {
            return summary.label ?? ""
        }
        // Spaced so VoiceOver reads each digit instead of one number.
        let spokenDigits = lastDigits.map(String.init).joined(separator: " ")
        return [summary.label, "ending in \(spokenDigits)"].compactMap { $0 }.joined(separator: ", ")
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
            .foregroundColor(pillContentColor)
            .accessibilityHidden(true)
    }

    // MARK: - Helpers

    /// PayPal Credit isn't a card, so it's shown by its label rather than card art and last digits.
    private func isPayPalCredit(_ summary: PayPalSavedPaymentMethod) -> Bool {
        summary.type == .payPalCredit
    }

    /// Shared by the visible text and the VoiceOver label so the two can't drift apart.
    /// `nil` when the FI is shown by its label alone: PayPal Credit, or no digits.
    private func lastDigits(for summary: PayPalSavedPaymentMethod) -> String? {
        guard !isPayPalCredit(summary), let lastDigits = summary.lastDigits, !lastDigits.isEmpty else {
            return nil
        }
        return lastDigits
    }

    private func fiText(for summary: PayPalSavedPaymentMethod) -> String {
        guard let lastDigits = lastDigits(for: summary) else {
            return summary.label ?? ""
        }
        // Card art conveys the brand; the text is just the masked last digits.
        return "••\(lastDigits)"
    }
}
