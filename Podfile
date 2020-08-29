source 'https://cdn.cocoapods.org/'

workspace 'Braintree.xcworkspace'
platform :ios, '11.0'
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
  target 'BraintreeVenmoTests'
end
