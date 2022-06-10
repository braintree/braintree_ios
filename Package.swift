// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Braintree",
    platforms: [.iOS(.v13)],
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
            targets: ["BraintreeCore", "BraintreeCoreSwift"]
        ),
        .library(
            name: "BraintreeCoreSwift",
            targets: ["BraintreeCoreSwift"]
        ),
        .library(
            name: "BraintreeDataCollector",
            targets: ["BraintreeDataCollector", "BraintreeKountDataCollector", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreePaymentFlow",
            targets: ["BraintreePaymentFlow", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreePayPal",
            targets: ["BraintreePayPal", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreeThreeDSecure",
            targets: ["BraintreeThreeDSecure", "CardinalMobile", "PPRiskMagnes"]
        ),
        .library(
            name: "BraintreeUnionPay",
            targets: ["BraintreeUnionPay"]
        ),
        .library(
            name: "BraintreeVenmo",
            targets: ["BraintreeVenmo"]
        ),
        .library(
            name: "BraintreeKountDataCollector",
            targets: ["BraintreeKountDataCollector", "KountDataCollector"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BraintreeAmericanExpress",
            dependencies: ["BraintreeCore"]
        ),
        .target(
            name: "BraintreeApplePay",
            dependencies: ["BraintreeCore"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeCard",
            dependencies: ["BraintreeCore"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeCore",
            dependencies: ["BraintreeCoreSwift"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeCoreSwift"
        ),
        .target(
            name: "BraintreeDataCollector",
            dependencies: ["BraintreeCore", "BraintreeKountDataCollector", "PPRiskMagnes"]
        ),
        .target(
            name: "BraintreePaymentFlow",
            dependencies: ["BraintreeCore", "BraintreeDataCollector"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreePayPal",
            dependencies: ["BraintreeCore", "BraintreeDataCollector"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeThreeDSecure",
            dependencies: ["BraintreePaymentFlow", "BraintreeCard", "CardinalMobile", "PPRiskMagnes"],
            publicHeadersPath: "Public",
            cSettings: [.headerSearchPath("V2UICustomization")]
        ),
        .binaryTarget(
            name: "CardinalMobile",
            path: "Frameworks/XCFrameworks/CardinalMobile.xcframework"
        ),
        .target(
            name: "BraintreeUnionPay",
            dependencies: ["BraintreeCard"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeVenmo",
            dependencies: ["BraintreeCore"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeKountDataCollector",
            dependencies: ["KountDataCollector"],
            publicHeadersPath: "Public"
        ),
        .binaryTarget(
            name: "KountDataCollector",
            path: "Frameworks/XCFrameworks/KountDataCollector.xcframework"
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
        )
    ]
)
