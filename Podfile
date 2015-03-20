source 'https://github.com/CocoaPods/Specs.git'

workspace 'Braintree.xcworkspace'

target 'Tests' do
  link_with 'Braintree-Specs',
            'Braintree-API-Specs',
            'Braintree-API-Integration-Specs',
            'Braintree-Payments-Specs',
            'Braintree-Payments-UI-Specs',
            'Braintree-PayPal-Specs',
            'Braintree-PayPal-Integration-Specs',
            'Braintree-PayPal-Acceptance-Specs',
            'Braintree-Venmo-Specs',
            'Braintree-Data-Specs',
            'Braintree-3D-Secure-Specs',
            'Braintree-Coinbase-Specs'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/Data', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/Coinbase', :path => '.'
  pod 'Specta', :git => 'https://github.com/specta/specta.git', :commit => 'v0.3.0.beta1'
  pod 'Expecta', '~> 0.3.0'
  pod 'OCMock', '~> 2.2.3'
  pod 'OCHamcrest', '~> 3.0.1'
  pod 'OHHTTPStubs', '~> 3.1.0'
  pod 'KIF', :git => 'https://github.com/mickeyreiss/KIF.git', :commit => '1702bb14dc1070650816e9a26ee5a03d6bdba41e'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'KIFViewControllerActions', :git => 'https://github.com/mickeyreiss/KIFViewControllerActions.git'
end

target 'Braintree-Dev' do
  link_with 'Braintree-Demo',
            'Braintree-API-Demo',
            'Braintree-PayPal-Demo',
            'Braintree-Data-Demo',
            'Braintree-UI-Demo'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/Data', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/Coinbase', :path => '.'
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.2'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'UIActionSheet+Blocks'
  pod 'UIAlertView+Blocks'
  pod 'FLEX'
  pod 'InAppSettingsKit'

pod 'coinbase-official', :git => 'https://github.com/braintreeps/coinbase-ios-sdk.git'
end

target 'Braintree-Apple-Pay-Excluded' do
  link_with 'Braintree-Apple-Pay-Excluded-Build-Specs'
  pod 'Braintree', :path => '.'
  pod 'OCMock', '~> 2.2.3'
end

target 'Braintree-Apple-Pay' do
  link_with 'Braintree-Apple-Pay-Build-Specs'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'OCMock', '~> 2.2.3'
end

post_install do |installer|
    targets = installer.project.targets.select{ |t| t.to_s.end_with? "-Braintree" }
    if (targets.count > 0)
        targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['RUN_CLANG_STATIC_ANALYZER'] = 'YES'
                config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] ||= 'YES'
                config.build_settings['GCC_WARN_ABOUT_MISSING_NEWLINE'] ||= 'YES'
            end
        end
    else
        puts "WARNING: Braintree targets not found"
    end
end

