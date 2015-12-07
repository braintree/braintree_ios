source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

workspace 'Braintree.xcworkspace'

def demo_pods
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.6.0'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'FLEX'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu'
end

def test_pods
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end

target 'Demo' do
  link_with 'Demo', 'Demo-StaticLibrary'
  demo_pods
end

target 'Test-Deps' do
  link_with 'UnitTests', 'IntegrationTests', 'UnitTests-StaticLibrary'
  test_pods
end

target 'UnitTests-CocoaPods' do
  test_pods
  pod 'Braintree', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/DataCollector', :path => '.'
  pod 'Braintree/Venmo', :path => '.'
end
