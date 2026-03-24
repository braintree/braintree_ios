# Braintree iOS SDK — Claude Code Context

## Project Overview

The Braintree iOS SDK is a multi-module Swift library that enables merchants to accept payments (credit card, PayPal, Venmo, Apple Pay, 3D Secure, and more) in iOS apps. It is distributed via Swift Package Manager, CocoaPods, and Carthage.

- **Minimum iOS**: 16.0
- **Minimum Swift**: 5.10
- **Minimum Xcode**: 16.2
- **Current version**: 7.x (see `Braintree.podspec` for exact version)

## Repository Structure

```
Sources/            # 13 SDK modules (one directory per module)
UnitTests/          # Unit test targets mirroring Sources/ structure
IntegrationTests/   # API-level integration tests
Demo/               # Sample app with UI tests (Braintree.xcworkspace)
SampleApps/         # Minimal apps for validating CocoaPods and SPM installs
Frameworks/         # Vendored binary frameworks (CardinalMobile, PPRiskMagnes)
Docs/               # Additional documentation
.github/workflows/  # GitHub Actions CI workflows
```

### SDK Modules (`Sources/`)

| Module | Purpose |
|---|---|
| `BraintreeCore` | Core networking (HTTP + GraphQL), config, auth, analytics |
| `BraintreeCard` | Credit/debit card tokenization |
| `BraintreePayPal` | PayPal checkout and vault flows |
| `BraintreeVenmo` | Venmo app switch integration |
| `BraintreeThreeDSecure` | 3D Secure via Cardinal Mobile SDK |
| `BraintreeApplePay` | Apple Pay integration |
| `BraintreeAmericanExpress` | AmEx rewards/card handling |
| `BraintreeDataCollector` | Device fingerprinting for fraud detection |
| `BraintreeLocalPayment` | Local/alternative payment methods |
| `BraintreeSEPADirectDebit` | SEPA Direct Debit payments |
| `BraintreeShopperInsights` | Shopper enrichment data |
| `BraintreePayPalMessaging` | Pay Later messaging UI |
| `BraintreeUIComponents` | Branded payment buttons (PayPal, Venmo) |

## Build & Development Setup

```bash
# Install dependencies (required before opening Xcode)
pod install

# Open the workspace (not the .xcodeproj)
open Braintree.xcworkspace

# Lint Swift code (must pass before merging)
swiftlint --strict
```

SwiftLint 0.55.1+ must be installed (`brew install swiftlint`).

## Running Tests

All tests are run via Xcode or `xcodebuild`. Target the `Braintree.xcworkspace`.

**Unit tests** — run per-module targets (e.g., `BraintreeCard_Tests`, `BraintreePayPal_Tests`).

**Integration tests** — require sandbox credentials; see `DEVELOPMENT.md`.

**UI tests** — run against the Demo app; require a booted simulator.

CI uses iPhone 16 Pro / iOS 18.5 simulator on macOS 15 with Xcode 16.4.

## Architecture & Key Patterns

### Client / Provider Split
Public-facing types are **Clients** (e.g., `BTCardClient`, `BTPayPalClient`). Internal implementation details live in **Providers** (e.g., `BTThreeDSecureV2Provider`). Keep this separation when adding new functionality.

### Async/Await + Completion Handler Parity
Every public client method must expose **both** an `async throws` variant and a completion-handler variant for backwards compatibility:

```swift
// Completion handler
func tokenize(_ card: BTCard, completion: @escaping (BTCardNonce?, Error?) -> Void)

// Async/await
func tokenize(_ card: BTCard) async throws -> BTCardNonce
```

Implement the async version as the primary path; have the callback variant call it with `Task { }`.

### Nonce Pattern
Tokenized payment data is represented as a `BTPaymentMethodNonce` subclass (e.g., `BTCardNonce`, `BTPayPalAccountNonce`). Nonces never expose raw card/account data — they are safe to pass to your server.

### Error Handling
Each module defines its own error enum conforming to `CustomNSError`, `LocalizedError`, and `Equatable`:

```swift
enum BTCardError: Int, Error, CustomNSError, LocalizedError, Equatable {
    case unknown
    case customerInputInvalid([String: Any])
    // ...
    static var errorDomain: String { "com.braintreepayments.BTCardClientErrorDomain" }
}
```

### Protocol-Based Abstraction
Key behaviors are protocol-backed to facilitate testing:
- `ClientAuthorization` — tokenization key vs. client token
- `URLOpener` — app switching
- `AnalyticsSendable` — analytics service injection
- `CardinalSessionTestable` — 3DS session testing

### Analytics
Every success/failure path should call `sendAnalyticsEvent` using the module's analytics enum (e.g., `BTCardAnalytics`, `BTPayPalAnalytics`). Analytics events are prefixed with the module name and use dot notation (e.g., `ios.card.tokenize.succeeded`).

### Configuration
`ConfigurationLoader` fetches and caches `BTConfiguration` asynchronously on first use. Feature flags (e.g., GraphQL enablement) live on `BTConfiguration`. Do not fetch config more than once per session.

## Coding Conventions

Follow `STYLE_GUIDE.md` in full. Key highlights:

- **Prefixes**: All public types use `BT` prefix (`BTCardClient`, `BTPayPalRequest`). Do not abbreviate further.
- **Acronyms**: Capitalize per Swift convention — `orderID`, `dataUTF8`, `url` (not `URL` when a variable).
- **MARK sections**: Use `// MARK: - Public Properties`, `// MARK: - Internal Properties`, `// MARK: - Initializer`, `// MARK: - Public Methods`, `// MARK: - Private Methods`, `// MARK: - <ProtocolName>` for conformance.
- **Protocol conformance**: Implement in a `// MARK: -` extension, not inline in the class body.
- **Implicit returns**: Preferred for single-expression functions and computed properties.
- **Weak self**: Always capture `[weak self]` in closures stored as properties or passed across async boundaries.
- **Documentation comments**: Public API must have `///` Markdown doc comments.

## Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Clients | `BT<Name>Client` | `BTCardClient` |
| Request models | `BT<Name>Request` | `BTPayPalRequest` |
| Nonce/result types | `BT<Name>Nonce` or `BT<Name>Result` | `BTCardNonce` |
| Error enums | `BT<Name>Error` | `BTThreeDSecureError` |
| Analytics enums | `BT<Name>Analytics` | `BTVenmoAnalytics` |
| Error domains | `com.braintreepayments.BT<Name>ErrorDomain` | `com.braintreepayments.BTCardClientErrorDomain` |

## Testing Conventions

- Test files mirror source files: `BTCardClient.swift` → `BTCardClient_Tests.swift`.
- Use `MockAPIClient` (from `BraintreeTestShared`) to stub `BTAPIClient` in unit tests.
- Use `OHHTTPStubs` for HTTP-level stubbing.
- Use `XCTestExpectation` for async callback tests; prefer `async`/`await` in new tests.
- Test both the happy path and error conditions.
- Verify analytics events are sent using `MockAPIClient.postedAnalyticsEvents`.

## Adding a New Module

1. Create `Sources/<ModuleName>/` with a `PrivacyInfo.xcprivacy` manifest.
2. Add the library product and target to `Package.swift`.
3. Add the corresponding subspec to `Braintree.podspec`.
4. Create `UnitTests/<ModuleName>_Tests/` and add the test target.
5. Follow the Client/Provider split, error enum, and analytics enum patterns above.

## Dependencies

**Runtime (binary frameworks — do not update without testing 3DS/fraud flows):**
- `CardinalMobile.xcframework` v2.2.5-9 — 3D Secure certification
- `PPRiskMagnes.xcframework` v5.6.0 — PayPal fraud detection
- `PayPalMessages.xcframework` v1.0.0 — Pay Later messaging UI

**Development only:**
- OCMock — Objective-C mocking
- OHHTTPStubs/Swift — HTTP stubbing
- xcbeautify — test output formatting

## CI / GitHub Actions

| Workflow | Trigger | What it checks |
|---|---|---|
| `tests.yml` | Pull request | Unit, integration, and UI tests |
| `build.yml` | Pull request | CocoaPods lint, Carthage build, SPM build |
| `swiftlint.yml` | Pull request | SwiftLint strict mode |
| `release.yml` | Manual / tag | Version bump and release automation |

All PRs must pass all three check workflows before merging.

## Key Files

- `Package.swift` — SPM module definitions and binary dependencies
- `Braintree.podspec` — CocoaPods distribution spec
- `Podfile` — development workspace dependencies
- `STYLE_GUIDE.md` — detailed Swift style rules (read before writing new code)
- `DEVELOPMENT.md` — environment setup and test running details
- `CHANGELOG.md` — version history
- `V7_MIGRATION.md` — migration guide from v6 (async/await changes)
