source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

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

target 'Demo' do
  link_with 'Demo', 'Demo-StaticLibrary'
  demo_pods
end

target 'Demo-CocoaPods' do
  demo_pods
  pod 'Braintree', :path => '.'
  pod 'Braintree/3D-Secure', :path => '.'
  pod 'Braintree/Apple-Pay', :path => '.'
  pod 'Braintree/DataCollector', :path => '.'
end

target 'Test-Deps' do
  link_with 'UnitTests', 'IntegrationTests', 'UnitTests-StaticLibrary', 'UnitTests-CocoaPods'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end

