Pod::Spec.new do |s|
  s.name             = "Braintree"
  s.version          = "5.7.0"
  s.summary          = "Braintree iOS SDK: Helps you accept card and alternative payments in your iOS app."
  s.description      = <<-DESC
                       Braintree is a full-stack payments platform for developers

                       This CocoaPod will help you accept payments in your iOS app.

                       Check out our development portal at https://developer.paypal.com/braintree/docs.
  DESC
  s.homepage         = "https://developer.paypal.com/braintree"
  s.documentation_url = "https://developer.paypal.com/braintree/docs/start/hello-client"
  s.license          = "MIT"
  s.author           = { "Braintree" => "team-bt-sdk@paypal.com" }
  s.source           = { :git => "https://github.com/braintree/braintree_ios.git", :tag => s.version.to_s }

  s.platform         = :ios, "12.0"
  s.compiler_flags   = "-Wall -Werror -Wextra"
  s.swift_version    = "5.1"

  s.default_subspecs = %w[Core Card PayPal]

  s.subspec "AmericanExpress" do |s|
    s.source_files  = "Sources/BraintreeAmericanExpress/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeAmericanExpress/Public/BraintreeAmericanExpress/*.h"
    s.dependency "Braintree/Core"
  end

  s.subspec "ApplePay" do |s|
    s.source_files  = "Sources/BraintreeApplePay/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeApplePay/Public/BraintreeApplePay/*.h"
    s.dependency "Braintree/Core"
    s.frameworks = "PassKit"
  end

  s.subspec "Card" do |s|
    s.source_files  = "Sources/BraintreeCard/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeCard/Public/BraintreeCard/*.h"
    s.dependency "Braintree/Core"
  end

  s.subspec "Core" do |s|
    s.source_files  = "Sources/BraintreeCore/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeCore/Public/BraintreeCore/*.h"
  end

  s.subspec "DataCollector" do |s|
    s.source_files = "Sources/BraintreeDataCollector/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeDataCollector/Public/BraintreeDataCollector/*.h"
    s.vendored_frameworks = "Frameworks/XCFrameworks/KountDataCollector.xcframework"
    s.dependency "Braintree/Core"
  end

  s.subspec "PaymentFlow" do |s|
    s.source_files = "Sources/BraintreePaymentFlow/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreePaymentFlow/Public/BraintreePaymentFlow/*.h"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPalDataCollector"
  end

  s.subspec "PayPal" do |s|
    s.source_files = "Sources/BraintreePayPal/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreePayPal/Public/BraintreePayPal/*.h"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPalDataCollector"
  end

  s.subspec "PayPalDataCollector" do |s|
    s.source_files = "Sources/PayPalDataCollector/**/*.{swift}"
    s.vendored_frameworks = "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
  end

  s.subspec "ThreeDSecure" do |s|
    s.source_files = "Sources/BraintreeThreeDSecure/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeThreeDSecure/Public/BraintreeThreeDSecure/*.h"
    s.dependency "Braintree/Card"
    s.dependency "Braintree/PaymentFlow"
    s.vendored_frameworks = "Frameworks/XCFrameworks/CardinalMobile.xcframework"
  end

  s.subspec "UnionPay" do |s|
    s.source_files  = "Sources/BraintreeUnionPay/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeUnionPay/Public/BraintreeUnionPay/*.h"
    s.dependency "Braintree/Card"
  end

  s.subspec "Venmo" do |s|
    s.source_files = "Sources/BraintreeVenmo/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeVenmo/Public/BraintreeVenmo/*.h"
    s.dependency "Braintree/Core"
  end

end
