source 'https://cdn.cocoapods.org/'

workspace 'Braintree.xcworkspace'
platform :ios, '14.0'
use_frameworks!
inhibit_all_warnings!

target 'Demo' do
  project 'Demo/Demo'
  pod 'InAppSettingsKit'
  pod 'VisaCheckoutSDK'
end

abstract_target 'Tests' do
  pod 'OCMock'
  pod 'OHHTTPStubs/Swift'
  pod 'xcbeautify'

  target 'IntegrationTests'
  target 'BraintreeCoreTests'
end

# Workaround required for Xcode 14.3 
# https://stackoverflow.com/questions/75574268/missing-file-libarclite-iphoneos-a-xcode-14-3
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end
