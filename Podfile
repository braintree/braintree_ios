source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
workspace 'Braintree.xcworkspace'

target 'Demo' do
  platform :ios, '9.0'

  pod 'AFNetworking', '~> 3.2.0'
  pod 'CardIO'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'InAppSettingsKit'
  pod 'iOS-Slide-Menu', :git => 'git@github.com:braintree/iOS-Slide-Menu.git', :branch => 'master'
  pod 'BraintreeDropIn', :podspec => 'BraintreeDropIn.podspec'
end

abstract_target 'Tests' do
  pod 'Specta', :git => 'git@github.com:specta/specta.git', :commit => 'f175b99aa4abeb63095d01a76bc6991c248fa877'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'

  target 'UnitTests'
  target 'IntegrationTests'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "BraintreeDropIn"
      target.build_configurations.each do |config|
        config.build_settings['HEADER_SEARCH_PATHS'] = '${PODS_ROOT}/../BraintreeCore/Public ${PODS_ROOT}/../BraintreeCard/Public ${PODS_ROOT}/../BraintreeUnionPay/Public ${PODS_ROOT}/../BraintreePaymentFlow/Public ${PODS_ROOT}/../BraintreePaymentFlow/Public/Ideal ${PODS_ROOT}/../BraintreePaymentFlow/Public/ThreeDSecure ${PODS_ROOT}/Headers/Private ${PODS_ROOT}/Headers/Private/BraintreeDropIn ${PODS_ROOT}/Headers/Public'
      end
    end
  end
end
