source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

workspace 'Braintree.xcworkspace'

target 'Braintree-Demo' do
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.6.0'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'FLEX'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu'
end

target 'Test-Deps' do
  link_with 'Braintree Unit Tests', 'BraintreeIntegrationTests'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end

