// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Braintree",
    platforms: [.iOS(.v12)],
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
        	targets: ["KountDataCollector", "BraintreeDataCollector"]
        ),
        .library(
            name: "BraintreePaymentFlow",
            targets: ["BraintreePaymentFlow"]
        ),
        .library(
            name: "BraintreePayPal",
            targets: ["BraintreePayPal"]
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
            name: "PayPalDataCollector",
            targets: ["PayPalDataCollector", "PPRiskMagnes"]
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
            dependencies: ["BraintreeCore"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeApplePay",
            dependencies: ["BraintreeCore"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeCard",
            dependencies: ["BraintreeCore"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeCore",
            dependencies: [],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeDataCollector",
            dependencies: ["BraintreeCore"],
            exclude: ["Kount"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreePaymentFlow",
            dependencies: ["BraintreeCore", "BraintreeCard", "PayPalDataCollector"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreePayPal",
            dependencies: ["BraintreeCore", "PayPalDataCollector"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeUnionPay",
            dependencies: ["BraintreeCore", "BraintreeCard"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeVenmo",
            dependencies: ["BraintreeCore", "PayPalDataCollector"],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public"
        ),
        .binaryTarget(
            name: "KountDataCollector",
            path: "Frameworks/KountDataCollector.xcframework"
        ),
        .target(
            name: "PayPalDataCollector",
            dependencies: ["BraintreeCore"],
            path: "Sources/PayPalDataCollector"
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/PPRiskMagnes.xcframework"
        )
    ]
)
