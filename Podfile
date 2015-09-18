source 'https://github.com/CocoaPods/Specs.git'

workspace 'Braintree.xcworkspace'

target 'Tests' do
  link_with 'Braintree-Acceptance-Specs',
            'Braintree-UI-Specs',
            'Braintree-PayPal-Specs',
            'Braintree-PayPal-Integration-Specs',
            'Braintree-Venmo-Specs',
            'Braintree-Data-Specs',
            'Braintree-3D-Secure-Specs',
            'Braintree-Coinbase-Integration-Specs'
  pod 'Specta', '~> 1.0.3'
  pod 'Expecta', '~> 1.0.2'
  pod 'OCMock', '~> 3.1'
  pod 'OCHamcrest', '~> 3.0.1'
  pod 'OHHTTPStubs', '~> 3.1.0'
  pod 'KIF', :git => 'https://github.com/kif-framework/KIF.git', :branch => 'master'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'KIFViewControllerActions', :git => 'https://github.com/mickeyreiss/KIFViewControllerActions.git'
end

target 'Braintree-Demo' do
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/Data', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/Coinbase', :path => '.'
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.6.0'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'FLEX'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu'
end

target 'Logic-Tests' do
  link_with 'Braintree-API-Specs',
            'Braintree-API-Integration-Specs',
            'Braintree-Payments-Specs',
            'Braintree-Specs'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/Data', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/Coinbase', :path => '.'
  pod 'Specta', '~> 1.0.3'
  pod 'Expecta', '~> 1.0.2'
  pod 'OCMock', '~> 3.1'
  pod 'OCHamcrest', '~> 3.0.1'
  pod 'OHHTTPStubs', '~> 3.1.0'
  pod 'NSURL+QueryDictionary', '~> 1.0'
end


target 'Braintree-Apple-Pay-Excluded' do
  link_with 'Braintree-Apple-Pay-Excluded-Build-Specs'
  pod 'Braintree', :path => '.'
  pod 'OCMock', '~> 3.1'
end

target 'Braintree-Apple-Pay' do
  link_with 'Braintree-Apple-Pay-Build-Specs'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'OCMock', '~> 3.1'
end

post_install do |installer|
    targets = installer.pods_project.targets.select{ |t| t.to_s.end_with? "-Braintree" }
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

