// swift-tools-version:5.10
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
            name: "BraintreePayPalMessaging",
            targets: ["BraintreePayPalMessaging"]
        ),
        .library(
            name: "BraintreeSEPADirectDebit",
            targets: ["BraintreeSEPADirectDebit"]
        ),
        .library(
            name: "BraintreeShopperInsights",
            targets: ["BraintreeShopperInsights"]
        ),
        .library(
            name: "BraintreeThreeDSecure",
            targets: ["BraintreeThreeDSecure", "CardinalMobile", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreeVenmo",
            targets: ["BraintreeVenmo"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/gicugavrisco/paypal-messages-ios.git",
            exact: "1.2.0"
        )
    ],
    targets: [
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
            name: "BraintreePayPalMessaging",
            dependencies: [
                "BraintreeCore",
                .product(name: "PayPalMessages", package: "paypal-messages-ios")
            ],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .binaryTarget(
            name: "PayPalCheckout",
            url: "https://github.com/paypal/paypalcheckout-ios/releases/download/1.3.0/PayPalCheckout.xcframework.zip",
            checksum: "d65186f38f390cb9ae0431ecacf726774f7f89f5474c48244a07d17b248aa035"
        ),
        .target(
            name: "BraintreeSEPADirectDebit",
            dependencies: ["BraintreeCore"],
            path: "Sources/BraintreeSEPADirectDebit",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "BraintreeShopperInsights",
            dependencies: ["BraintreeCore"],
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
