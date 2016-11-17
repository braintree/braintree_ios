source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
workspace 'Braintree.xcworkspace'

abstract_target 'Tests' do
  target 'Braintree-Acceptance-Specs'
  target 'Braintree-UI-Specs'
  target 'Braintree-PayPal-Specs'
  target 'Braintree-PayPal-Integration-Specs'
  target 'Braintree-Venmo-Specs'
  target 'Braintree-Data-Specs'
  target 'Braintree-3D-Secure-Specs'
  target 'Braintree-Coinbase-Integration-Specs'

  pod 'Specta', '~> 1.0.3'
  pod 'Expecta', '~> 1.0.2'
  pod 'OCMock', '~> 3.1'
  pod 'OCHamcrest', '~> 3.0.1'
  pod 'OHHTTPStubs', '~> 3.1.0'
  pod 'KIF', '~> 3.5.1'
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

abstract_target 'Logic-Tests' do
  target 'Braintree-API-Specs'
  target 'Braintree-API-Integration-Specs'
  target 'Braintree-Payments-Specs'
  target 'Braintree-Specs'

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


abstract_target 'Braintree-Apple-Pay-Excluded' do
  target 'Braintree-Apple-Pay-Excluded-Build-Specs'
  pod 'Braintree', :path => '.'
  pod 'OCMock', '~> 3.1'
end

abstract_target 'Braintree-Apple-Pay' do
  target 'Braintree-Apple-Pay-Build-Specs'
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

