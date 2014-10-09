source 'https://github.com/CocoaPods/Specs.git'

workspace 'Braintree.xcworkspace'

target 'Tests' do
  link_with 'Braintree-Specs',
            'Braintree-API-Specs',
            'Braintree-API-Integration-Specs',
            'Braintree-Payments-Specs',
            'Braintree-Payments-UI-Specs',
            'Braintree-PayPal-Specs',
            'Braintree-PayPal-Integration-Specs',
            'Braintree-PayPal-Acceptance-Specs',
            'Braintree-Venmo-Specs',
            'Braintree-Data-Specs'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Data', :path => '.'
  pod 'Specta', :git => 'https://github.com/specta/specta.git', :tag => 'v0.3.0.beta1'
  pod 'Expecta', '~> 0.3.0'
  pod 'OCMock', '~> 2.2.3'
  pod 'OCHamcrest', '~> 3.0.1'
  pod 'OHHTTPStubs', '~> 3.1.0'
  pod 'KIF', '~> 3.0'
  pod 'NSURL+QueryDictionary', '~> 1.0'
end

target 'Braintree-Dev' do
  link_with 'Braintree-Demo',
            'Braintree-API-Demo',
            'Braintree-PayPal-Demo',
            'Braintree-Data-Demo',
            'Braintree-Payments-UI-Demo'
  pod 'Braintree', :path => '.'
  pod 'Braintree/Data', :path => '.'
  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.2'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'UIActionSheet+Blocks'
  pod 'UIAlertView+Blocks'
  pod 'FLEX'
end
