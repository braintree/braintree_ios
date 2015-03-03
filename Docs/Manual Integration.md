Manual Integration Without CocoaPods
------------------------------------

Please follow these instructions to integrate Braintree iOS into your app without CocoaPods.

> Note: We assume that you are using Xcode 6.1 and iOS 8 as
your Base SDK.

1. Add the Braintree iOS SDK code to your repository
  - Use git: `git submodule add https://github.com/braintree/braintree_ios.git`
  - Alternatively, you can [download braintree_ios from Github](https://github.com/braintree/braintree_ios/archive/master.zip) and unzip it into your app's root directory in Finder
2. Open up your app in Xcode
3. Create a a new framework target called `Braintree` (please use this exact name)
  - In Xcode, select `File > New > Target`
  - Click `Framework & Library`
  - Click `Cocoa Touch Framework` and `Next`
  - Product Name: `Braintree`
  - Language: `Objective C`
  - Embed in Application: `[your app target]`
  - You will now see a new `Braintree` Target Dependency in your main app target (in the first section of `Build Phases`).
4. Add the Braintree code to project
  - The code is located in `braintree-ios/Braintree`
  - In Xcode, select `File` > `Add Files to [...]...`
  - Select `braintree-ios/Braintree`
  - Add to targets: `Braintree` (your newly created framework target)
  - Optionally check `Copy items if needed`
5. Remove .md files from Braintree build
  - Select on your project file in the project navigator
  - Under `Targets`, select the `Braintree` target.
  - Under `Build Phases` > `Compile Sources`, remove all .md files
6. Link system frameworks for  `Braintree`
  - Under `Braintree` > `Build Phases` > `Link Binary With Libraries`, add the following system frameworks:
    - `AVFoundation.framework`
    - `AudioToolbox.framework`
    - `CoreLocation.framework`
    - `CoreMedia.framework`
    - `Foundation.framework`
    - `MessageUI.framework`
    - `MobileCoreServices.framework`
    - `PassKit.framework`
    - `SystemConfiguration.framework`
    - `UIKit.framework`
  - Weak link `PassKit.framework` by changing its Status from `Required` to `Optional`.
7. Modify `Braintree` build settings
  - Under `Braintree` > `Build Settings`, add `-lc++ -ObjC` to `Other Linker Flags`
8. Remove the `Braintree` scheme
  - In Xcode, select `Product` > `Scheme` > `Manage Schemes...`
  - Delete `Braintree`
9. Optionally, to include Apple Pay in your app:
  - Add `BT_ENABLE_APPLE_PAY=1` to `Preprocessor Macros` in both the `Braintree` > `Build Settings` and in your target's `Build Settings`.
10. Build and Run your app to test out the integration
11. [Integrate the SDK in your checkout form](https://developers.braintreepayments.com/ios/start/overview)

