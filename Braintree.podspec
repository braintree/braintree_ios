Pod::Spec.new do |s|
  s.name             = "Braintree"
  s.version          = "5.27.0"
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
  s.swift_version    = "5.9"

  s.default_subspecs = %w[Core Card PayPal]

  s.subspec "AmericanExpress" do |s|
    s.source_files  = "Sources/BraintreeAmericanExpress/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeAmericanExpress/Public/BraintreeAmericanExpress/*.h"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeAmericanExpress_PrivacyInfo" => "Sources/BraintreeAmericanExpress/PrivacyInfo.xcprivacy" }
  end

  s.subspec "ApplePay" do |s|
    s.source_files  = "Sources/BraintreeApplePay/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeApplePay/Public/BraintreeApplePay/*.h"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeApplePay_PrivacyInfo" => "Sources/BraintreeApplePay/PrivacyInfo.xcprivacy" }
    s.frameworks = "PassKit"
  end

  s.subspec "Card" do |s|
    s.source_files  = "Sources/BraintreeCard/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeCard/Public/BraintreeCard/*.h"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeCard_PrivacyInfo" => "Sources/BraintreeCard/PrivacyInfo.xcprivacy" }
  end

  s.subspec "Core" do |s|
    s.source_files  = "Sources/BraintreeCore/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeCore/Public/BraintreeCore/*.h"
    s.resource_bundle = { "BraintreeCore_PrivacyInfo" => "Sources/BraintreeCore/PrivacyInfo.xcprivacy" }
  end

  s.subspec "DataCollector" do |s|
    s.source_files = "Sources/BraintreeDataCollector/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeDataCollector/Public/BraintreeDataCollector/*.h"
    s.vendored_frameworks = "Frameworks/XCFrameworks/KountDataCollector.xcframework"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeDataCollector_PrivacyInfo" => "Sources/BraintreeDataCollector/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PaymentFlow" do |s|
    s.source_files = "Sources/BraintreePaymentFlow/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreePaymentFlow/Public/BraintreePaymentFlow/*.h"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPalDataCollector"
    s.resource_bundle = { "BraintreePaymentFlow_PrivacyInfo" => "Sources/BraintreePaymentFlow/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PayPal" do |s|
    s.source_files = "Sources/BraintreePayPal/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreePayPal/Public/BraintreePayPal/*.h"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPalDataCollector"
    s.resource_bundle = { "BraintreePayPal_PrivacyInfo" => "Sources/BraintreePayPal/PrivacyInfo.xcprivacy" }
  end

  s.subspec "SEPADirectDebit" do |s|
    s.source_files = "Sources/BraintreeSEPADirectDebit/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeSEPADirectDebit_PrivacyInfo" => "Sources/BraintreeSEPADirectDebit/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PayPalDataCollector" do |s|
    s.source_files = "Sources/PayPalDataCollector/**/*.{swift}"
    s.vendored_frameworks = "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
    s.resource_bundle = { "PayPalDataCollector_PrivacyInfo" => "Sources/PayPalDataCollector/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PayPalNativeCheckout" do |s|
    s.source_files = "Sources/BraintreePayPalNativeCheckout/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPal"
    s.dependency "PayPalCheckout", '0.110.0'
    s.resource_bundle = { "BraintreePayPalNativeCheckout_PrivacyInfo" => "Sources/BraintreePayPalNativeCheckout/PrivacyInfo.xcprivacy" }
  end

  s.subspec "ThreeDSecure" do |s|
    s.source_files = "Sources/BraintreeThreeDSecure/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeThreeDSecure/Public/BraintreeThreeDSecure/*.h"
    s.dependency "Braintree/Card"
    s.dependency "Braintree/PaymentFlow"
    s.vendored_frameworks = "Frameworks/XCFrameworks/CardinalMobile.xcframework"
    s.resource_bundle = { "BraintreeThreeDSecure_PrivacyInfo" => "Sources/BraintreeThreeDSecure/PrivacyInfo.xcprivacy" }
  end

  s.subspec "UnionPay" do |s|
    s.source_files  = "Sources/BraintreeUnionPay/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeUnionPay/Public/BraintreeUnionPay/*.h"
    s.dependency "Braintree/Card"
    s.resource_bundle = { "BraintreeUnionPay_PrivacyInfo" => "Sources/BraintreeUnionPay/PrivacyInfo.xcprivacy" }
  end

  s.subspec "Venmo" do |s|
    s.source_files = "Sources/BraintreeVenmo/**/*.{h,m}"
    s.public_header_files = "Sources/BraintreeVenmo/Public/BraintreeVenmo/*.h"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeVenmo_PrivacyInfo" => "Sources/BraintreeVenmo/PrivacyInfo.xcprivacy" }
  end

end
