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

  target 'UnitTests'
  target 'IntegrationTests'
  target 'BraintreeCoreTests'
  target 'BraintreeVenmoTests'
end
