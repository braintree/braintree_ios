// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Braintree",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "BraintreeAmericanExpress",
            targets: ["BraintreeAmericanExpress"]
        ),
        .library(
            name: "BraintreeApplePay",
            targets: ["BraintreeApplePay"]
        ),
        .library(
            name: "BraintreeCard",
            targets: ["BraintreeCard"]
        ),
        .library(
            name: "BraintreeCore",
            targets: ["BraintreeCore"]
        ),
        .library(
            name: "BraintreeDataCollector",
            targets: ["BraintreeDataCollector", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreeLocalPayment",
            targets: ["BraintreeLocalPayment", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreePayPal",
            targets: ["BraintreePayPal", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreePayPalNativeCheckout",
            targets: ["BraintreePayPalNativeCheckout"]
        ),
        .library(
            name: "BraintreeSEPADirectDebit",
            targets: ["BraintreeSEPADirectDebit"]
        ),
        .library(
            name: "BraintreeThreeDSecure",
            targets: ["BraintreeThreeDSecure", "CardinalMobile", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreeVenmo",
            targets: ["BraintreeVenmo"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BraintreeAmericanExpress",
            dependencies: ["BraintreeCore"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeApplePay",
            dependencies: ["BraintreeCore"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeCard",
            dependencies: ["BraintreeCore"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeCore",
            exclude: ["Info.plist", "Braintree.h"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeDataCollector",
            dependencies: ["BraintreeCore", "PPRiskMagnes"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeLocalPayment",
            dependencies: ["BraintreeCore", "BraintreeDataCollector"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreePayPal",
            dependencies: ["BraintreeCore", "BraintreeDataCollector"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreePayPalNativeCheckout",
            dependencies: ["BraintreeCore", "BraintreePayPal", "PayPalCheckout"],
            path: "Sources/BraintreePayPalNativeCheckout",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .binaryTarget(
            name: "PayPalCheckout",
            url: "https://github.com/paypal/paypalcheckout-ios/releases/download/1.2.0/PayPalCheckout.xcframework.zip",
            checksum: "de177ea050cfd342aa1bbfe0d9ed7faf8262270a0291a5862b6ee3c7f85cc1ff"
        ),
        .target(
            name: "BraintreeSEPADirectDebit",
            dependencies: ["BraintreeCore"],
            path: "Sources/BraintreeSEPADirectDebit",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeThreeDSecure",
            dependencies: ["BraintreeCard", "CardinalMobile", "PPRiskMagnes", "BraintreeCore"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .binaryTarget(
            name: "CardinalMobile",
            path: "Frameworks/XCFrameworks/CardinalMobile.xcframework"
        ),
        .target(
            name: "BraintreeVenmo",
            dependencies: ["BraintreeCore"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
        )
    ]
)
