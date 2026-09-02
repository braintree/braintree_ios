import Foundation

/// Determines which funding instrument the Braintree GraphQL API resolves, and therefore which identity field is required.
enum BTPayPalFundingInstrumentFetchType: String {

    /// The default funding instrument vaulted on the buyer's billing agreement. Resolved from the client token's payment method ID JWT.
    case stickyFI = "STICKY_FI"

    /// The funding instrument the buyer selected while approving a checkout. Resolved from that order's ID.
    case fiFromApprovedCheckout = "FI_FROM_APPROVED_CHECKOUT"
}
