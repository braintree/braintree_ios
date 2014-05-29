Pod::Spec.new do |s|
  s.name             = "Braintree"
  s.version          = "3.0.0-rc1"
  s.summary          = "Accept payments in your app"
  s.description      = <<-DESC
                       Braintree is a full-stack payments platform for developers

                       This library will enable your app to accept payments safely
                       and easily.
  DESC
  s.homepage         = "https://braintreepayments.com"
  s.license          = 'MIT'
  s.author           = { "Braintree" => "code@getbraintree.com" }
  s.source           = { :git => "git@github.com:braintree/braintree_ios_preview.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/braintree'

  s.platform         = :ios, '6.0'
  s.requires_arc     = true

  s.source_files     = 'Braintree/*.{m,h}'

  s.compiler_flags = "-Wall -Werror -Wextra"
  s.xcconfig = { "GCC_TREAT_WARNINGS_AS_ERRORS" => "YES" }

  s.subspec 'Drop-In' do |s|
    s.source_files  = "Braintree/Drop-In/**/*.{h,m}"
    s.public_header_files = "Braintree/Drop-In/Public/*.h"
    s.dependency 'Braintree/api'
    s.dependency 'Braintree/PayPal'
    s.dependency 'Braintree/UI'
  end

  s.subspec 'api' do |s|
    s.source_files  = "Braintree/api/Braintree-API/**/*.{h,m}"
    s.public_header_files = "Braintree/api/Braintree-API/Public/*.h"
    s.dependency 'AFNetworking', '~> 2.2'
  end

  s.subspec 'PayPal' do |s|
    s.source_files  = "Braintree/PayPal/Braintree-PayPal/**/*.{h,m}"
    s.public_header_files = "Braintree/PayPal/Braintree-PayPal/**/*.h"
    s.frameworks = "AVFoundation", "CoreLocation", "MessageUI", "SystemConfiguration"
    s.vendored_library = "Braintree/PayPal/Braintree-PayPal/PayPalMobileSDK/libPayPalMobile.a"
    s.xcconfig = { "GCC_TREAT_WARNINGS_AS_ERRORS" => "YES", "OTHER_LDFLAGS" => "-ObjC -lc++" }
    s.dependency 'Braintree/api'
    s.dependency 'Braintree/UI'
  end

  s.subspec 'UI' do |s|
    s.source_files  = 'Braintree/UI/Braintree-Payments-UI/**/*.{h,m}'
    s.public_header_files = 'Braintree/UI/Braintree-Payments-UI/**/*.h'
    s.compiler_flags = "-Wall -Wextra"
    s.frameworks = 'UIKit'
  end
end
