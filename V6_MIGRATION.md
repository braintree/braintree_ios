# Braintree iOS v6 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v5 to v6.

_Documentation for v6 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
1. [App Context Switching](#app-context-switching)

## Supported Versions

v6 supports a minimum deployment target of iOS 13+. It requires the use of Xcode 13+ and Swift 5.1+. If your application contains Objective-C code, the `Enable Modules` build setting must be set to `YES`.

## App Context Switching

v6 removes the `handleOpenURL` method on `BTAppContextSwitcher` in favor of `handleOpenURLContext`.

In your `UISceneDelegate`, use the following code to pass a return URL to `BTAppContextSwitcher`:

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
  URLContexts.forEach { context in
    if context.url.scheme?.localizedCaseInsensitiveCompare("com.your-company.your-app.payments") == .orderedSame {
      BTAppContextSwitcher.handleOpenURLContext(urlContext)
    }
  }
}
```

This change was made because iOS 13 requires `UISceneDelegate`s and Braintree v6 bumps its minimum supported deployment target to iOS 13.
