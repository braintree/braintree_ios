Pod::Spec.new do |s|
  s.name             = "Braintree"
  s.version          = "6.20.0"
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

  s.platform         = :ios, "14.0"
  s.compiler_flags   = "-Wall -Werror -Wextra"
  s.swift_version    = "5.9"

  s.default_subspecs = %w[Core Card PayPal]

  s.subspec "AmericanExpress" do |s|
    s.source_files  = "Sources/BraintreeAmericanExpress/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeAmericanExpress_PrivacyInfo" => "Sources/BraintreeAmericanExpress/PrivacyInfo.xcprivacy" }
  end

  s.subspec "ApplePay" do |s|
    s.source_files  = "Sources/BraintreeApplePay/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeApplePay_PrivacyInfo" => "Sources/BraintreeApplePay/PrivacyInfo.xcprivacy" }
    s.frameworks = "PassKit"
  end

  s.subspec "Card" do |s|
    s.source_files  = "Sources/BraintreeCard/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeCard_PrivacyInfo" => "Sources/BraintreeCard/PrivacyInfo.xcprivacy" }
  end

  s.subspec "Core" do |s|
    s.source_files  = "Sources/BraintreeCore/**/*.{swift,h}"
    s.public_header_files = "Sources/BraintreeCore/*.h"
    s.resource_bundle = { "BraintreeCore_PrivacyInfo" => "Sources/BraintreeCore/PrivacyInfo.xcprivacy" }
  end

  s.subspec "DataCollector" do |s|
    s.source_files = "Sources/BraintreeDataCollector/*.swift"
    s.dependency "Braintree/Core"
    s.vendored_frameworks = "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
    s.resource_bundle = { "BraintreeDataCollector_PrivacyInfo" => "Sources/BraintreeDataCollector/PrivacyInfo.xcprivacy"}
  end

  s.subspec "LocalPayment" do |s|
    s.source_files = "Sources/BraintreeLocalPayment/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/DataCollector"
    s.resource_bundle = { "BraintreeLocalPayment_PrivacyInfo" => "Sources/BraintreeLocalPayment/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PayPal" do |s|
    s.source_files = "Sources/BraintreePayPal/**/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/DataCollector"
    s.resource_bundle = { "BraintreePayPal_PrivacyInfo" => "Sources/BraintreePayPal/PrivacyInfo.xcprivacy" }
  end

  s.subspec "SEPADirectDebit" do |s|
    s.source_files = "Sources/BraintreeSEPADirectDebit/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeSEPADirectDebit_PrivacyInfo" => "Sources/BraintreeSEPADirectDebit/PrivacyInfo.xcprivacy" }
  end

  s.subspec "ShopperInsights" do |s|
    s.source_files = "Sources/BraintreeShopperInsights/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeShopperInsights_PrivacyInfo" => "Sources/BraintreeShopperInsights/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PayPalNativeCheckout" do |s|
    s.source_files = "Sources/BraintreePayPalNativeCheckout/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPal"
    s.dependency "PayPalCheckout", '1.3.0'
    s.resource_bundle = { "BraintreePayPalNativeCheckout_PrivacyInfo" => "Sources/BraintreePayPalNativeCheckout/PrivacyInfo.xcprivacy" }
  end

  s.subspec "PayPalMessaging" do |s|
    s.source_files = "Sources/BraintreePayPalMessaging/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "PayPalMessages", '1.0.0'
    s.resource_bundle = { "BraintreePayPalMessaging_PrivacyInfo" => "Sources/BraintreePayPalMessaging/PrivacyInfo.xcprivacy" }
  end

  s.subspec "ThreeDSecure" do |s|
    s.source_files = "Sources/BraintreeThreeDSecure/**/*.{swift}"
    s.dependency "Braintree/Card"
    s.vendored_frameworks = "Frameworks/XCFrameworks/CardinalMobile.xcframework"
    s.resource_bundle = { "BraintreeThreeDSecure_PrivacyInfo" => "Sources/BraintreeThreeDSecure/PrivacyInfo.xcprivacy" }
  end

  s.subspec "Venmo" do |s|
    s.source_files = "Sources/BraintreeVenmo/*.swift"
    s.dependency "Braintree/Core"
    s.resource_bundle = { "BraintreeVenmo_PrivacyInfo" => "Sources/BraintreeVenmo/PrivacyInfo.xcprivacy" }
  end

end
