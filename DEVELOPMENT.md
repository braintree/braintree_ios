# Braintree iOS Development Notes

This document outlines development practices that we follow while developing this SDK.

## Development Merchant Server

The included demo app utilizes a [sandbox sample merchant server](https://braintree-sample-merchant.herokuapp.com) hosted on Heroku.

## SwiftLint

Ensure that you have [SwiftLint](https://github.com/realm/SwiftLint) installed as we utilize it within our project.

To install via [Homebrew](https://brew.sh/) run:
```
brew install swiftlint
```
Our Xcode workspace has a `Run Phase` which integrates in `SwiftLint` so the only prerequisite is installing via `Homebrew`.

## Style Guide
While we use SwiftLint in the SDK to adhere to a general style, there are some guidelines that are not able to be captured by our linter rules. Those guidelines are defined in our [style guide](STYLE_GUIDE.md). Please refer to these when developing for the SDK.

## Tests

Each module has a corresponding unit test target. These can be run individually, or all at once via the `UnitTests` scheme.

To run the tests:
1. Fetch test dependencies
    * `pod install`
1. Run tests
    * `xcodebuild test -workspace Braintree.xcworkspace -scheme UnitTests -destination 'platform=iOS Simulator,name=iPhone 14'`
    * **OR** via the Xcode UI by selecting the `UnitTests` scheme + `⌘U`

_Note:_ Running the `UI` and `IntegrationTests` schemes follows the same steps as above, just replacing the `UnitTests` scheme name in step 3.

## Releasing

Refer to the `ios/releases` section in the internal SDK Knowledge Repo.
