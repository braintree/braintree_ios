// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Braintree",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "BraintreeCore",
            targets: ["BraintreeCore"]
        ),
        .library(
            name: "BraintreeCard",
            targets: ["BraintreeCard"]
        ),
        .library(
            name: "BraintreeApplePay",
            targets: ["BraintreeApplePay"]
        ),
        .library(
            name: "PayPalUtils",
            targets: ["PayPalUtils"]
        ),
        .library(
            name: "BraintreeAmericanExpress",
            targets: ["BraintreeAmericanExpress"]
        ),
        .library(
            name: "BraintreeUnionPay",
            targets: ["BraintreeUnionPay"]
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
            name: "BraintreeCore",
            dependencies: [],
            path: "BraintreeCore",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeCard",
            dependencies: ["BraintreeCore"],
            path: "BraintreeCard",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public",
            cSettings: [
                // TODO: This is currently necessary in a couple of modules because we are using project level
                // headers to expose some Core functionality to Card. I haven't been able to find anything equivalent
                // for SPM, so we may need to come up with a new strategy
                .headerSearchPath("../BraintreeCore/")
            ]
        ),
        .target(
            name: "BraintreeApplePay",
            dependencies: ["BraintreeCore"],
            path: "BraintreeApplePay",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../BraintreeCore/")
            ]
        ),
        .target(
            name: "PayPalUtils",
            dependencies: ["BraintreeCore"],
            path: "BraintreePayPal/PayPalUtils",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public"
        ),
        .target(
            name: "BraintreeAmericanExpress",
            dependencies: ["BraintreeCore"],
            path: "BraintreeAmericanExpress",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../BraintreeCore/")
            ]
        ),
        .target(
            name: "BraintreeUnionPay",
            dependencies: ["BraintreeCore", "BraintreeCard"],
            path: "BraintreeUnionPay",
            exclude: ["Info.plist"],
            sources: nil,
            resources: nil,
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../BraintreeCore/"),
                .headerSearchPath("../BraintreeCard/")
            ]
        ),
    ]
)
