// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Braintree",
    platforms: [.iOS(.v11)],
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
            name: "BraintreeUnionPay",
            targets: ["BraintreeUnionPay"]
        ),
        .library(
            name: "PayPalUtils",
            targets: ["PayPalUtils"]
        ),
        .library(
            name: "PayPalDataCollector",
            targets: ["PayPalDataCollector", "PPRiskMagnes"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
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
            name: "BraintreeUnionPay",
            dependencies: ["BraintreeCore", "BraintreeCard"],
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../BraintreeCore/"),
                .headerSearchPath("../BraintreeCard/")
            ]
        ),
        .target(
            name: "PayPalDataCollector",
            dependencies: ["BraintreeCore", "PayPalUtils"],
            path: "Sources/BraintreePayPal/PayPalDataCollector",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../BraintreeCore/"),
                .headerSearchPath("../BraintreeCard/")
            ]
        ),
        .target(
            name: "PayPalUtils",
            dependencies: ["BraintreeCore"],
            path: "Sources/BraintreePayPal/PayPalUtils",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public"
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/PPRiskMagnes.xcframework"
        ),
    ]
)
