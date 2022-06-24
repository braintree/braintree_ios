source 'https://cdn.cocoapods.org/'

workspace 'Braintree.xcworkspace'
platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'Demo' do
  project 'Demo/Demo'
  pod 'InAppSettingsKit'
end

abstract_target 'Tests' do
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
  pod 'xcbeautify'

  target 'IntegrationTests'
  target 'BraintreeCoreTests'
end

# https://github.com/CocoaPods/CocoaPods/issues/7314
post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
