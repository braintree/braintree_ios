source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

workspace 'Braintree.xcworkspace'

target 'Demo' do
  platform :ios, '9.0'

  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.6.0'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'FLEX'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu'
  pod 'BraintreeDropIn'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/UnionPay', :path => '.'
  pod 'Braintree/Venmo', :path => '.'
  pod 'Braintree/DataCollector', :path => '.'
end

abstract_target 'Tests' do
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'

  target 'UnitTests'
  target 'IntegrationTests'
end

