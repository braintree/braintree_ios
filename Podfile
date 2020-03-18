source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

workspace 'Braintree.xcworkspace'

target 'Demo' do
  platform :ios, '9.0'

  pod 'Braintree/Core', :path => './'
  pod 'Braintree/Apple-Pay', :path => './'
  pod 'Braintree/Card', :path => './'
  pod 'Braintree/DataCollector', :path => './'
  pod 'Braintree/PayPal', :path => './'
  pod 'Braintree/Venmo', :path => './'
  pod 'Braintree/UI', :path => './'
  pod 'Braintree/UnionPay', :path => './'
  pod 'Braintree/3D-Secure', :path => './'
  pod 'Braintree/PayPalDataCollector', :path => './'
  pod 'Braintree/PayPalUtils', :path => './'
  pod 'Braintree/AmericanExpress', :path => './'
  pod 'Braintree/PaymentFlow', :path => './'
  
  pod 'NSURL+QueryDictionary', '~> 1.0', :inhibit_warnings => true
  pod 'PureLayout', :inhibit_warnings => true
  pod 'InAppSettingsKit', :inhibit_warnings => true
  pod 'BraintreeDropIn', :podspec => 'BraintreeDropIn.podspec'
end

abstract_target 'Tests' do
  pod 'Specta', :inhibit_warnings => true
  pod 'Expecta', :inhibit_warnings => true
  pod 'OCMock', :inhibit_warnings => true
  pod 'OHHTTPStubs', :inhibit_warnings => true

  target 'UnitTests'
  target 'IntegrationTests'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "BraintreeDropIn"
      target.build_configurations.each do |config|
        config.build_settings['HEADER_SEARCH_PATHS'] = '${PODS_ROOT}/../BraintreeCore/Public ${PODS_ROOT}/../BraintreeCard/Public ${PODS_ROOT}/../BraintreeUnionPay/Public ${PODS_ROOT}/../BraintreePaymentFlow/Public ${PODS_ROOT}/../BraintreePaymentFlow/Public/LocalPayment ${PODS_ROOT}/../BraintreePaymentFlow/Public/ThreeDSecure ${PODS_ROOT}/../BraintreePayPal/Public ${PODS_ROOT}/Headers/Private ${PODS_ROOT}/Headers/Private/BraintreeDropIn ${PODS_ROOT}/Headers/Public'
      end
    end
  end
end
