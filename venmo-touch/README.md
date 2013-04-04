Venmo Touch makes it easier for mobile apps to accept credit card payments.

When a user adds a credit card to *any* app in the Venmo network, they can make that card available for use inside other apps in the network by checking the `VTCheckboxView` checkbox.

Once a user has stored a card with Venmo, any app can then present the `VTCardView` when that user views a checkout screen.  The user can tap "Use Card" to give the merchant app the credit card information which that user stored with Venmo.

When a user taps "Use Card," the merchant app receives the same Braintree payment token and data (maintaining all of our existing [data portability standards](https://www.braintreepayments.com/landing/data-portability-policy)). From the merchant app perspective, **the result is exactly the same as if the user had manually filled out the credit card form during the checkout process**.

The VenmoTouch framework has support for iOS 5.0 or higher; it compiles on earlier versions of iOS, but in an unsupported iOS version, `[[VTClient alloc] init...]` will simply return nil, no delegate methods will trigger, and no network calls will be made.
