#
# Be sure to run `pod spec lint Braintree.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |spec|
  spec.name         = "Braintree"
  spec.version      = "2.0.0"
  spec.summary      = "Braintree and Venmo Touch for iOS."
  spec.homepage     = "https://braintreepayments.com/docs/ios"
  spec.license      = 'MIT'
  spec.author       = { "Braintree" => "email@address.com" }
  spec.author       = { "Braintree" => "code@getbraintree.com" }
  spec.source       = { :git => "https://github.com/braintree/braintree_ios.git", :tag => "2.0.0" }
  spec.ios.deployment_target = '5.0'
  
  ### Subspecs
  
  spec.subspec 'BTEncryption' do |subspec|
    subspec.source_files =  'braintree/BTEncryption/*.{h,m}'
  end

  # spec.subspec 'BTPayment' do |subspec|
  #   subspec.source_files =  'braintree/BTPayment/*.{h,m}'
  # end
  # 
  
  spec.requires_arc = true
end
