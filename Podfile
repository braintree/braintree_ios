def pods_for_specs
  pod 'Specta', '~> 0.2.1'
  pod 'Expecta', '~> 0.3.0'
  pod 'OCMock', '~> 2.2.3'
  pod 'OCHamcrest', '~> 3.0.1'
end


# Braintree #
target 'Braintree-Demo' do
  pod 'Braintree', :path => '.'

  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.2'
end

target 'Braintree-Specs' do
  pods_for_specs

  pod 'Braintree', :path => '.'
end


# API #
target 'Braintree-API-Specs' do
  pod 'Braintree/API', :path => '.'

  pod 'OHHTTPStubs', '~> 3.1.0'

  pods_for_specs
end

target 'Braintree-API-Integration-Specs' do
  pod 'Braintree/API', :path => '.'

  pods_for_specs
end

target 'Braintree-API-Demo' do
  pod 'Braintree/API', :path => '.'
end


# PayPal #
target 'Braintree-PayPal-Specs' do
  pod 'Braintree/PayPal', :path => '.'

  pod 'OHHTTPStubs', '~> 3.1.0'

  pods_for_specs
end

target 'Braintree-PayPal-Integration-Specs' do
  pod 'Braintree/PayPal', :path => '.'
  pods_for_specs
end

target 'Braintree-PayPal-Demo' do
  pod 'Braintree/PayPal', :path => '.'
end

target 'Braintree-PayPal-Acceptance-Specs' do
  pod 'KIF', '~> 3.0'

  pods_for_specs
end


# UI #
target 'Braintree-Payments-UI-Demo' do
  pod 'Braintree/UI', :path => '.'
end

target 'Braintree-Payments-UI-Specs' do
  pod 'Braintree/UI', :path => '.'

  pods_for_specs
end

# Data #
target 'Braintree-Data-Specs' do
  pods_for_specs
  pod 'Braintree/Data', :path => '.'
end

target 'Braintree-Data-Demo' do
  pod 'Braintree/Data', :path => '.'
end
