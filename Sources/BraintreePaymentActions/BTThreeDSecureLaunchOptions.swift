import Foundation

/// Options for customizing the 3D Secure challenge presented during the M4 drive path.
///
/// Replicates the four 3DS UI options from the existing `BTThreeDSecureRequest` (`uiType`,
/// `renderTypes`, `v2UICustomization`, `requestorAppURL`) with the same legacy-equivalent defaults —
/// an options value built with no arguments configures Cardinal exactly as those defaults do. No
/// Cardinal type is ever on this type's (or its leaf types') public surface.
///
/// Pass this as the optional third argument when creating a `BTPaymentActionsClient` (not the
/// server-side `threeDSecureOptions` field used when creating the Payment Action, which is a
/// different thing). It applies to every call the client makes — if the app is killed, re-create the
/// client with the same options, since a challenge restarted with different options can mismatch
/// what the issuer was already told.
@objcMembers public class BTThreeDSecureLaunchOptions: NSObject {

    // MARK: - Public Properties

    /// Sets all UI types that the device supports for displaying specific challenge user interfaces
    /// in the 3D Secure challenge. Defaults to `.both`.
    public var uiType: BTThreeDSecureLaunchUIType = .both

    /// Optional: list of all the render types that the device supports for displaying specific
    /// challenge user interfaces. `nil` is derived from `uiType`.
    public var renderTypes: [BTThreeDSecureLaunchRenderType]?

    /// Optional: UI customization for 3DS2 challenge views.
    public var uiCustomization: BTThreeDSecureLaunchUICustomization?

    /// Optional: the 3DS requestor app URL, declaring this app's URL within the CReq message, for an
    /// out-of-band bank app to return the customer to this app. `nil`: the SDK derives a
    /// package-scoped link.
    public var requestorAppURL: URL?
}
