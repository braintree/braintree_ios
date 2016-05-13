source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

workspace 'Braintree.xcworkspace'

target 'Demo' do
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.6.0'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'FLEX'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu'

  abstract_target 'Tests' do
    inherit! :search_paths

    pod 'Specta'
    pod 'Expecta'
    pod 'OCMock'
    pod 'OHHTTPStubs'

    target 'UnitTests'
    target 'IntegrationTests'
  end
end

