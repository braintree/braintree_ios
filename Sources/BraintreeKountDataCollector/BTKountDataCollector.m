#if __has_include(<Braintree/BraintreeKountDataCollector.h>)
#import <Braintree/BraintreeKountDataCollector.h>
#else
#import <BraintreeKountDataCollector/BraintreeKountDataCollector.h>
#endif

/// For Swift Package Manager we need a dummy .m file as we cannot have a module with only .h files.
/// Swift forum reference: https://forums.swift.org/t/swift-package-and-xcframework-target-for-c-library-where-to-include-the-header/51163
/// Stackoverflow reference: https://stackoverflow.com/questions/68502255/how-to-define-obj-c-target-with-a-header-file-so-other-targets-can-implement-it
/// This file needs to have something other than an import statement in it and this keep int should not be used and is instead a dummy item for Swift Package Manager.
int _keep;
