import SwiftUI
import BraintreePayPalSavedPaymentMethod

/// The knobs of `PayPalSavedPaymentMethodViewStyle`, flattened so each one can be bound
/// individually. A `nil` value is left unset on the style, so the SDK applies its own default.
struct PayPalSavedPaymentMethodStyleConfig {

    var showPayPalLogo = true
    var showPayPalLabel = true
    var showPayPalCreditMessaging = true

    var backgroundColor: Color?
    var textColor: Color?
    var baseFontSize: CGFloat?
    var fontName: String?

    var height: CGFloat?
    var horizontalPadding: CGFloat?
    var verticalPadding: CGFloat?
    var cornerRadius: CGFloat?
    var borderColor: Color?
    var borderWidth: CGFloat?

    var logoWidth: CGFloat?
    var labelFontSize: CGFloat?
    var labelLeadingGap: CGFloat?

    var fundingInstrumentTextFontSize: CGFloat?
    var editIconSize: CGFloat?
    var fundingInstrumentLeadingGap: CGFloat?

    var creditMessagingFontSize: CGFloat?
    var creditMessagingLinkColor: Color?

    var style: PayPalSavedPaymentMethodViewStyle {
        PayPalSavedPaymentMethodViewStyle(
            showPayPalLogo: showPayPalLogo,
            showPayPalLabel: showPayPalLabel,
            showPayPalCreditMessaging: showPayPalCreditMessaging,
            componentAppearance: .init(
                backgroundColor: backgroundColor.map { UIColor($0) },
                textColor: textColor.map { UIColor($0) },
                baseFontSize: baseFontSize,
                fontName: fontName
            ),
            container: .init(
                height: height,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                cornerRadius: cornerRadius,
                borderColor: borderColor.map { UIColor($0) },
                borderWidth: borderWidth,
                logo: .init(width: logoWidth),
                label: .init(fontSize: labelFontSize, leadingGap: labelLeadingGap),
                fundingInstrument: .init(
                    textFontSize: fundingInstrumentTextFontSize,
                    editIconSize: editIconSize,
                    leadingGap: fundingInstrumentLeadingGap
                ),
                creditMessaging: .init(
                    fontSize: creditMessagingFontSize,
                    linkColor: creditMessagingLinkColor.map { UIColor($0) }
                )
            )
        )
    }
}

/// Presents every merchant-configurable style value so the component can be re-themed at runtime.
struct PayPalSavedPaymentMethodStyleEditor: View {

    @Binding var config: PayPalSavedPaymentMethodStyleConfig

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                visibilitySection
                appearanceSection
                containerSection
                logoAndLabelSection
                fundingInstrumentSection
                creditMessagingSection
            }
            .navigationTitle("Component Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        config = PayPalSavedPaymentMethodStyleConfig()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var visibilitySection: some View {
        Section("Visibility") {
            SwiftUI.Toggle("PayPal Logo", isOn: $config.showPayPalLogo)
            SwiftUI.Toggle("PayPal Label", isOn: $config.showPayPalLabel)
            SwiftUI.Toggle("Credit Messaging", isOn: $config.showPayPalCreditMessaging)
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            OptionalColorRow(title: "Background Color", defaultColor: .white, value: $config.backgroundColor)
            OptionalColorRow(title: "Text Color", defaultColor: Color(white: 0.133), value: $config.textColor)
            OptionalMetricRow(title: "Base Font Size", defaultValue: 14, value: $config.baseFontSize)

            Picker("Font", selection: fontSelection) {
                Text("System").tag("")
                Text("Georgia").tag("Georgia")
                Text("Courier").tag("Courier")
                Text("Chalkduster").tag("Chalkduster")
            }
        }
    }

    private var containerSection: some View {
        Section("Container") {
            OptionalMetricRow(title: "Height", defaultValue: 48, range: 0...200, value: $config.height)
            OptionalMetricRow(title: "Horizontal Padding", defaultValue: 0, value: $config.horizontalPadding)
            OptionalMetricRow(title: "Vertical Padding", defaultValue: 10, value: $config.verticalPadding)
            OptionalMetricRow(title: "Corner Radius", defaultValue: 0, range: 0...40, value: $config.cornerRadius)
            OptionalColorRow(title: "Border Color", defaultColor: .gray, value: $config.borderColor)
            OptionalMetricRow(title: "Border Width", defaultValue: 1, range: 0...10, value: $config.borderWidth)
        }
    }

    private var logoAndLabelSection: some View {
        Section("Logo and Label") {
            OptionalMetricRow(title: "Logo Width", defaultValue: 48, range: 0...120, value: $config.logoWidth)
            OptionalMetricRow(title: "Label Font Size", defaultValue: 20, value: $config.labelFontSize)
            OptionalMetricRow(title: "Label Leading Gap", defaultValue: 13, value: $config.labelLeadingGap)
        }
    }

    private var fundingInstrumentSection: some View {
        Section("Funding Instrument") {
            OptionalMetricRow(title: "Text Font Size", defaultValue: 14, value: $config.fundingInstrumentTextFontSize)
            OptionalMetricRow(title: "Edit Icon Size", defaultValue: 16, value: $config.editIconSize)
            OptionalMetricRow(title: "Leading Gap", defaultValue: 8, value: $config.fundingInstrumentLeadingGap)
        }
    }

    private var creditMessagingSection: some View {
        Section("Credit Messaging") {
            OptionalMetricRow(title: "Font Size", defaultValue: 16, value: $config.creditMessagingFontSize)
            OptionalColorRow(title: "Link Color", defaultColor: .blue, value: $config.creditMessagingLinkColor)
        }
    }

    private var fontSelection: Binding<String> {
        Binding(
            get: { config.fontName ?? "" },
            set: { config.fontName = $0.isEmpty ? nil : $0 }
        )
    }
}

/// A point value the merchant may leave unset. Off hands `nil` to the SDK; on reveals a stepper.
private struct OptionalMetricRow: View {

    let title: String
    let defaultValue: CGFloat
    var range: ClosedRange<CGFloat> = 0...60
    @Binding var value: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Toggle(title, isOn: isSet)

            if let value {
                Stepper("\(Int(value)) pt", value: amount, in: range)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var isSet: Binding<Bool> {
        Binding(
            get: { value != nil },
            set: { value = $0 ? defaultValue : nil }
        )
    }

    private var amount: Binding<CGFloat> {
        Binding(
            get: { value ?? defaultValue },
            set: { value = $0 }
        )
    }
}

/// A color the merchant may leave unset. Off hands `nil` to the SDK; on reveals a color well.
private struct OptionalColorRow: View {

    let title: String
    let defaultColor: Color
    @Binding var value: Color?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Toggle(title, isOn: isSet)

            if value != nil {
                ColorPicker("Color", selection: color)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var isSet: Binding<Bool> {
        Binding(
            get: { value != nil },
            set: { value = $0 ? defaultColor : nil }
        )
    }

    private var color: Binding<Color> {
        Binding(
            get: { value ?? defaultColor },
            set: { value = $0 }
        )
    }
}

#Preview {
    PayPalSavedPaymentMethodStyleEditor(config: .constant(PayPalSavedPaymentMethodStyleConfig()))
}
