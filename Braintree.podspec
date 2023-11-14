Pod::Spec.new do |s|
  s.name             = "Braintree"
  s.version          = "6.8.0"
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
  s.swift_version    = "5.8"

  s.default_subspecs = %w[Core Card PayPal]

  s.subspec "AmericanExpress" do |s|
    s.source_files  = "Sources/BraintreeAmericanExpress/*.swift"
    s.dependency "Braintree/Core"
  end

  s.subspec "ApplePay" do |s|
    s.source_files  = "Sources/BraintreeApplePay/*.swift"
    s.dependency "Braintree/Core"
    s.frameworks = "PassKit"
  end

  s.subspec "Card" do |s|
    s.source_files  = "Sources/BraintreeCard/*.swift"
    s.dependency "Braintree/Core"
  end

  s.subspec "Core" do |s|
    s.source_files  = "Sources/BraintreeCore/**/*.{swift,h}"
    s.public_header_files = "Sources/BraintreeCore/*.h"
  end

  s.subspec "DataCollector" do |s|
    s.source_files = "Sources/BraintreeDataCollector/*.swift"
    s.dependency "Braintree/Core"
    s.vendored_frameworks = "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
  end

  s.subspec "LocalPayment" do |s|
    s.source_files = "Sources/BraintreeLocalPayment/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/DataCollector"
  end

  s.subspec "PayPal" do |s|
    s.source_files = "Sources/BraintreePayPal/**/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/DataCollector"
  end

  s.subspec "SEPADirectDebit" do |s|
    s.source_files = "Sources/BraintreeSEPADirectDebit/*.swift"
    s.dependency "Braintree/Core"
  end

  s.subspec "PayPalNativeCheckout" do |s|
    s.source_files = "Sources/BraintreePayPalNativeCheckout/*.swift"
    s.dependency "Braintree/Core"
    s.dependency "Braintree/PayPal"
    s.dependency "PayPalCheckout", '1.2.0'
  end

  s.subspec "ThreeDSecure" do |s|
    s.source_files = "Sources/BraintreeThreeDSecure/**/*.{swift}"
    s.dependency "Braintree/Card"
    s.vendored_frameworks = "Frameworks/XCFrameworks/CardinalMobile.xcframework"
  end

  s.subspec "Venmo" do |s|
    s.source_files = "Sources/BraintreeVenmo/*.swift"
    s.dependency "Braintree/Core"
  end

end
