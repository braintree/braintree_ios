source 'https://cdn.cocoapods.org/'

workspace 'Braintree.xcworkspace'
platform :ios, '12.0'
use_frameworks!

target 'Demo' do
  project 'Demo/Demo'
  pod 'InAppSettingsKit', :inhibit_warnings => true
end

abstract_target 'Tests' do
  pod 'Specta', :inhibit_warnings => true
  pod 'Expecta', :inhibit_warnings => true
  pod 'OCMock', :inhibit_warnings => true
  pod 'OHHTTPStubs', :inhibit_warnings => true
  pod 'xcbeautify', :inhibit_warnings => true

  target 'UnitTests'
  target 'IntegrationTests'
  target 'BraintreeCoreTests'
  target 'BraintreeVenmoTests'
end

# https://github.com/CocoaPods/CocoaPods/issues/7314
post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
