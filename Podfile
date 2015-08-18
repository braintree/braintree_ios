source 'https://github.com/CocoaPods/Specs.git'

workspace 'Braintree.xcworkspace'

target 'Braintree-Demo' do
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.2'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'FLEX', :git => 'https://github.com/intelliot/FLEX.git'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu'
end

target 'Test-Deps' do
  link_with 'Braintree Unit Tests', 'BraintreeIntegrationTests'
  pod 'Specta'
  pod 'Expecta', '~> 0.3.0'
  pod 'OCMock', '~> 3.1'
  pod 'OHHTTPStubs', '~> 3.1.0'
end

