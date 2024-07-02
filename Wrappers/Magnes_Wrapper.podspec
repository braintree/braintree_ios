Pod::Spec.new do |s|  
    s.name              = 'Magnes_Wrapper'
    s.version           = '0.0.1'
    s.summary           = 'Your framework summary'
    s.homepage          = "https://developer.paypal.com/braintree"

    s.author            = { 'Name' => 'you@yourcompany.com' }
    s.license           = { :type => 'MIT', :file => '../LICENSE' }

    s.source            = { :http => 'https://assets.braintreegateway.com/mobile/ios/carthage-frameworks/pp-risk-magnes/PPRiskMagnes.5.5.0-static-version-Xcode15-MinOSVersion100.xcframework.zip' }
    s.platform          = :ios
    s.ios.deployment_target = '14.0'
    s.ios.vendored_frameworks = '**/PPRisskMagnes.xcframework'
end