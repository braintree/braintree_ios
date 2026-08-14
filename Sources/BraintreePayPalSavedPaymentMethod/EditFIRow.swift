import SwiftUI
import UIKit

/// The funding-instrument chip: `[badge] PayPal  [ card-art •• 1234  ✎ ]`.
///
/// The brand mark (badge + "PayPal") sits on the left; the FI (card art + last digits + edit
/// pencil) sits in a rounded pill to its right. Renders three variants:
/// - `.instrument` — card art (or generic fallback glyph) + last digits + edit pencil
/// - `.displayOnly` — buyer email + edit pencil (no-FI-but-email fallback)
/// - `.brandOnly` — PayPal brand mark only (no-network fallback)
struct EditFIRow: View {

    enum Content: Equatable {
        case instrument(BTPayPalSavedPaymentMethodFISummary)
        case displayOnly(email: String)
        case brandOnly
    }

    let content: Content
    let style: BTPayPalSavedPaymentMethodViewStyle
    let onEdit: () -> Void

    // MARK: - Layout constants

    /// Gap between the card thumbnail and the masked number (the "view" group).
    private let viewGroupSpacing: CGFloat = 4
    /// Gap between the "view" group and the edit pencil.
    private let viewEditSpacing: CGFloat = 8
    private let cardArtWidth: CGFloat = 28
    private let cardArtHeight: CGFloat = 20

    // MARK: - Derived style values (guarded)

    private var textColor: Color {
        Color(uiColor: style.theme.textColorBase ?? UIColor(white: 0.133, alpha: 1))
    }

    private var fiFont: Font {
        BTPayPalSavedPaymentMethodFont.font(
            name: style.theme.fontName,
            size: EditFiStyleGuard.fiTextFontSize(style.container.fiCluster.textFontSize)
        )
    }

    private var editIconSide: CGFloat {
        EditFiStyleGuard.editIconSize(style.container.fiCluster.editIconSize)
    }

    private var fiClusterGap: CGFloat {
        EditFiStyleGuard.fiClusterLeadingGap(style.container.fiCluster.leadingGap)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            brandCluster

            switch content {
            case .instrument(let summary):
                fiPill {
                    HStack(spacing: viewEditSpacing) {
                        HStack(spacing: viewGroupSpacing) {
                            fiIcon(for: summary)
                            Text(fiText(for: summary))
                                .font(fiFont)
                                .foregroundColor(textColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        editButton
                    }
                }
                .padding(.leading, fiClusterGap)
            case .displayOnly(let email):
                fiPill {
                    HStack(spacing: viewEditSpacing) {
                        Text(email)
                            .font(fiFont)
                            .foregroundColor(textColor)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        editButton
                    }
                }
                .padding(.leading, fiClusterGap)
            case .brandOnly:
                EmptyView()
            }

            // Keep the cluster left-aligned; the pill hugs the brand mark.
            Spacer(minLength: 0)
        }
    }

    // MARK: - Subviews

    private var brandCluster: some View {
        PayPalBrandCluster(style: style)
    }

    /// The rounded pill wrapping the FI content + edit pencil.
    private func fiPill<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, EditFiStyleGuard.fiClusterHorizontalPadding(style.container.fiCluster.horizontalPadding))
            .padding(.vertical, EditFiStyleGuard.fiClusterVerticalPadding(style.container.fiCluster.verticalPadding))
            .background(pillBackground)
    }

    @ViewBuilder private var pillBackground: some View {
        if let color = style.container.fiCluster.backgroundColor {
            RoundedRectangle(cornerRadius: EditFiStyleGuard.fiClusterCornerRadius(style.container.fiCluster.cornerRadius))
                .fill(Color(uiColor: color))
        }
    }

    @ViewBuilder private func fiIcon(for summary: BTPayPalSavedPaymentMethodFISummary) -> some View {
        Group {
            if let url = summary.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    default:
                        // No-image-load fallback → generic glyph.
                        fallbackGlyph(for: summary)
                    }
                }
            } else {
                fallbackGlyph(for: summary)
            }
        }
        .frame(width: cardArtWidth, height: cardArtHeight)
        .background(cardIconBackground)
        .clipShape(RoundedRectangle(cornerRadius: cardIconRadius))
        .overlay(cardIconBorder)
        .accessibilityHidden(true)
    }

    private var cardIconRadius: CGFloat {
        EditFiStyleGuard.cardIconCornerRadius(style.container.fiCluster.cardIconCornerRadius)
    }

    @ViewBuilder private var cardIconBorder: some View {
        if let color = style.container.fiCluster.cardIconBorderColor {
            RoundedRectangle(cornerRadius: cardIconRadius)
                .strokeBorder(
                    Color(uiColor: color),
                    lineWidth: EditFiStyleGuard.cardIconBorderWidth(style.container.fiCluster.cardIconBorderWidth)
                )
        }
    }

    @ViewBuilder private var cardIconBackground: some View {
        if let color = style.container.fiCluster.cardIconBackgroundColor {
            RoundedRectangle(cornerRadius: cardIconRadius).fill(Color(uiColor: color))
        }
    }

    private func fallbackGlyph(for summary: BTPayPalSavedPaymentMethodFISummary) -> some View {
        Image("FundingIcon", bundle: .payPalSavedPaymentMethod)
            .resizable()
            .scaledToFit()
    }

    private var editButton: some View {
        Button(action: onEdit) {
            Image("EditPencil", bundle: .payPalSavedPaymentMethod)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: editIconSide, height: editIconSide)
                .foregroundColor(textColor)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit payment method")
        .accessibilityHint("Change the funding instrument PayPal will charge")
    }

    // MARK: - Helpers

    private func fiText(for summary: BTPayPalSavedPaymentMethodFISummary) -> String {
        guard let lastDigits = summary.lastDigits, !lastDigits.isEmpty else {
            return summary.label
        }
        // Card art conveys the brand; the text is just the masked last digits.
        return "••\(lastDigits)"
    }
}

/// The PayPal brand mark: `[badge] PayPal`. Shared by the loaded row and the loading skeleton
/// so the brand stays visible while the FI loads.
struct PayPalBrandCluster: View {

    let style: BTPayPalSavedPaymentMethodViewStyle

    private var textColor: Color {
        Color(uiColor: style.theme.textColorBase ?? UIColor(white: 0.133, alpha: 1))
    }

    private var labelFont: Font {
        BTPayPalSavedPaymentMethodFont.font(
            name: style.theme.fontName,
            size: EditFiStyleGuard.labelFontSize(style.container.label.fontSize),
            weight: .bold
        )
    }

    /// The PayPal logo (48×30 artwork) sits in a square (1:1) container. `logo.width` sets the
    /// side (default 48); the artwork scales to fit inside, preserving its own aspect ratio.
    static let defaultLogoSide: CGFloat = 48

    private var logoSide: CGFloat {
        if let width = style.container.logo.width {
            return EditFiStyleGuard.logoWidth(width)
        }
        return Self.defaultLogoSide
    }

    var body: some View {
        HStack(spacing: EditFiStyleGuard.labelLeadingGap(style.container.label.leadingGap)) {
            if style.showLogo {
                Image("PayPalBadge", bundle: .payPalSavedPaymentMethod)
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSide, height: logoSide)
                    .accessibilityHidden(true)
            }
            if style.showLabel {
                Text("PayPal")
                    .font(labelFont)
                    .foregroundColor(textColor)
                    .fixedSize()
            }
        }
    }
}
