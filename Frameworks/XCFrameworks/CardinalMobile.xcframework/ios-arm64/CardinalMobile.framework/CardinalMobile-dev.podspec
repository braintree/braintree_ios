Pod::Spec.new do |s|

  s.name         = "CardinalMobile-dev"
  s.version      = "3.0.0"
  s.summary      = "A comprehensive SDK for integrating Cardinal's authentication and payment services into iOS applications."
  s.description  = "The CardinalMobile SDK provides a robust set of tools and features designed to facilitate the integration of Cardinal's authentication and payment solutions into iOS applications. With support for 3-D Secure 2.0, this SDK ensures secure and seamless transaction processing, enhancing user experience and reducing fraud. Developers can leverage the SDK's capabilities to implement advanced security measures, streamline payment flows, and ensure compliance with global standards. Detailed documentation and a developer-friendly interface make integration straightforward and efficient"
  s.homepage     = "https://developer.cardinaltrusted.com/docs/ios-implementation"
  s.author             = { "Cardinal Commerce support" => "ccomsupportinbox@visa.com" }
  s.platform     = :ios, "12.0"
  s.source       = { :http => "https://cardinalcommerceprod.jfrog.io/artifactory/ios_cocoapods/#{s.version}/CardinalMobile.tar.gz" }

  s.vendored_frameworks = 'CardinalMobile.xcframework'
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
end
