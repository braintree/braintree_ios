Pod::Spec.new do |s|
  s.name             = "Braintree"
  s.version          = "3.3.1"
  s.summary          = "Braintree v.zero SDK. Accept payments in your app"
  s.description      = <<-DESC
                       Braintree is a full-stack payments platform for developers

                       This CocoaPod will help you accept credit card and PayPal payments in your iOS app.

                       Check out our development portal at https://developers.braintreepayments.com.
  DESC
  s.homepage         = "https://www.braintreepayments.com/v.zero"
  s.screenshots      = "https://raw.githubusercontent.com/braintree/braintree_ios/master/screenshot.png"
  s.license          = "MIT"
  s.author           = { "Braintree" => "code@getbraintree.com" }
  s.source           = { :git => "https://github.com/braintree/braintree_ios.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/braintree"

  s.platform         = :ios, "7.0"
  s.requires_arc     = true

  s.source_files     = "Braintree/*.{m,h}"

  s.compiler_flags = "-Wall -Werror -Wextra"
  s.xcconfig = { "GCC_TREAT_WARNINGS_AS_ERRORS" => "YES" }

  s.default_subspecs = %w[Drop-In API PayPal Venmo UI Payments]

  s.subspec "Drop-In" do |s|
    s.source_files  = "Braintree/Drop-In/**/*.{h,m}"
    s.public_header_files = "Braintree/Drop-In/Public/*.h"
    s.dependency "Braintree/API"
    s.dependency "Braintree/PayPal"
    s.dependency "Braintree/UI"
    s.dependency "Braintree/Venmo"
    s.dependency "Braintree/Payments"
    s.resource_bundle = { "Braintree-Drop-In-Localization" => "Braintree/Drop-In/Braintree-Drop-In/Localization/*.lproj" }
  end

  s.subspec "API" do |s|
    s.source_files  = "Braintree/API/Braintree-API/**/*.{h,m}"
    s.public_header_files = "Braintree/API/Braintree-API/Public/*.h"
  end

  s.subspec "PayPal" do |s|
    s.source_files = "Braintree/PayPal/Braintree-PayPal/**/*.{h,m}"
    s.public_header_files = "Braintree/PayPal/Braintree-PayPal/**/*.h"
    s.frameworks = "AVFoundation", "CoreLocation", "MessageUI", "SystemConfiguration"
    s.vendored_library = "Braintree/PayPal/Braintree-PayPal/PayPalMobileSDK/libPayPalMobile.a"
    s.xcconfig = { "GCC_TREAT_WARNINGS_AS_ERRORS" => "YES", "OTHER_LDFLAGS" => "-ObjC -lc++" }
    s.dependency "Braintree/API"
    s.dependency "Braintree/UI"
  end

  s.subspec "Venmo" do |s|
    s.source_files = "Braintree/Venmo/Braintree-Venmo/**/*.{h,m}"
    s.public_header_files = "Braintree/Venmo/Braintree-Venmo/**/*.h"
    s.compiler_flags = "-Wall -Wextra"
    s.dependency "Braintree/API"
  end

  s.subspec "UI" do |s|
    s.source_files  = "Braintree/UI/Braintree-Payments-UI/**/*.{h,m}"
    s.public_header_files = "Braintree/UI/Braintree-Payments-UI/**/*.h"
    s.compiler_flags = "-Wall -Wextra"
    s.frameworks = "UIKit"
    s.resource_bundle = { "Braintree-UI-Localization" => "Braintree/UI/Braintree-Payments-UI/Localization/*.lproj" }
  end

  s.subspec "Data" do |s|
    s.source_files = "Braintree/Data/Braintree-Data/**/*.{h,m}"
    s.vendored_library = "Braintree/Data/Braintree-Data/libDeviceCollectorLibrary.a"
    s.frameworks = "UIKit", "SystemConfiguration"
    s.dependency "Braintree/PayPal"
    s.dependency "Braintree/API"
  end

  s.subspec "Payments" do |s|
    s.source_files = "Braintree/Payments/Braintree-Payments/**/*.{h,m}"
    s.public_header_files = "Braintree/Payments/Braintree-Payments/Public/*.h"
    s.frameworks = "UIKit"
    s.dependency "Braintree/API"
    s.dependency "Braintree/PayPal"
    s.dependency "Braintree/Venmo"
  end
end
