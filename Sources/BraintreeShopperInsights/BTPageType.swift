import Foundation

/// The type of page where the payment button is displayed or where an event occured.
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTPageType: String {

    /// A home page is the primary landing page that a visitor will view when they navigate to a website.
    case homepage = "homepage"

    /// An About page is a section on a website that provides information about a company, organization, or individual.
    case about = "about"

    /// A contact page is a page on a website for visitors to contact the organization or individual providing the website.
    case contact = "contact"

    /// An intermediary step that users pass through on their way to a product-listing page that doesn't provide a complete
    /// list of products but may showcase a few products and provide links to product subcategories.
    case productCategory = "product_category"

    /// A product detail page (PDP) is a web page that outlines everything customers and buyers need to know about a
    /// particular product.
    case productDetails = "product_details"

    /// The page a user sees after entering a search query.
    case search = "search"

    /// A cart is a digital shopping cart that allows buyers to inspect and organize items they plan to buy.
    case cart = "cart"

    /// A checkout page is the page related to payment and shipping/billing details on an eCommerce store.
    case checkout = "checkout"

    /// An order review page gives the buyer an overview of the goods or services that they have selected and summarizes
    /// the order that they are about to place.
    case orderReview = "order_review"

    /// The order confirmation page summarizes an order after checkout completes.
    case orderConfirmation = "order_confirmation"

    /// Popup cart displayed after “add to cart” click.
    case miniCart = "mini_cart"

    /// Any other page available on a merchant’s site.
    case other = "other"
}
