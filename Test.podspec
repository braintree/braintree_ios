Pod::Spec.new do |s|  
    s.name              = 'Test'
    s.version           = '0.0.1'
    s.summary           = 'Your framework summary'
    s.homepage          = "https://developer.paypal.com/braintree"

    s.author            = { 'Name' => 'you@yourcompany.com' }
    s.license           = { :type => 'MIT', :file => '../LICENSE' }

    s.source            = { :http => 'https://assets.braintreegateway.com/mobile/ios/carthage-frameworks/cardinal-mobile/CardinalMobile.2.2.5-9.xcframework.zip' }
    s.platform          = :ios
    s.ios.deployment_target = '14.0'
    s.ios.vendored_frameworks = '**/CardinalMobile.xcframework'
end