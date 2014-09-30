workspace 'Braintree.xcworkspace'

def pods_for_specs
  pod 'Specta', :git => 'https://github.com/specta/specta.git', :branch => '0.3-wip'
  pod 'Expecta', '~> 0.3.0'
  pod 'OCMock', '~> 2.2.3'
  pod 'OCHamcrest', '~> 3.0.1'
end


# Braintree #
target 'Braintree-Demo' do
  pod 'Braintree', :path => '.'

  pod 'HockeySDK'
  pod 'AFNetworking', '~> 2.2'
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'PureLayout'
  pod 'UIActionSheet+Blocks'
  pod 'UIAlertView+Blocks'
  pod 'FLEX'
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

# Venmo #
target 'Braintree-Venmo-Specs' do
  pod 'Braintree/Venmo', :path => '.'
  pod 'NSURL+QueryDictionary', '~> 1.0'
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

# Payments #
target 'Braintree-Payments-Specs' do
  pods_for_specs
  pod 'Braintree/Payments'
end


# Add '$(PLATFORM_DIR)/Developer/Library/Frameworks' to Specta targets
# Fixes http://stackoverflow.com/questions/24275470/xctest-xctest-h-not-found-on-old-projects-built-in-xcode-6
# via http://stackoverflow.com/a/25078857/306657
post_install do |installer|
    targets = installer.project.targets.select{ |t| t.to_s.include? "Specta" }
    if (targets.count > 0)
        targets.each do |target|
            target.build_configurations.each do |config|
                s = config.build_settings['FRAMEWORK_SEARCH_PATHS']
                s = [ '$(inherited)' ] if s == nil;
                s.push('$(PLATFORM_DIR)/Developer/Library/Frameworks')
                config.build_settings['FRAMEWORK_SEARCH_PATHS'] = s
            end
        end
    else
        puts "WARNING: Specta targets not found"
    end
end
