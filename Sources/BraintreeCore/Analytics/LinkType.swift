/// Used to describe the type of link that directs users to a specific URL for analytics
/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum LinkType: String {
    case universal
    case deeplink
}
