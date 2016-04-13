Static Integration Guide
------------------------------------

Please follow these instructions to integrate Braintree iOS into your app without CocoaPods.

> Note: We assume that you are using Xcode 7+ and iOS 9.0+ as your Base SDK.

1. Add the Braintree iOS SDK code to your repository
  - [Download the SDK as a ZIP file from GitHub](https://github.com/braintree/braintree_ios/archive/master.zip) and unzip it into your app's root directory in Finder
2. Open up your app in Xcode
3. Add Braintree as a Sub Project
  - Open your project and drag the Braintree.xcodeproj file to your Project Navigator under your project. Be sure to *NOT* have the Braintree.xcodeproj open while doing this step.
  
  ![Screenshot of adding Braintree as a Sub Project](bt_static_screenshot_sub_project.png)
  
4. Add `Braintree` to your build phases (`[Your App Target]` > `Build Phases`)
  - `Target Dependencies`
    - Click the `+` and add `Braintree`
    
    ![Screenshot of adding Braintree to Target Dependencies](bt_static_screenshot_target_dependency.gif)
    
  - `Link Binary With Libraries`
    - Click the `+` and add `libBraintree.a`
    
    ![Screenshot of adding Braintree to Link Bunary With Libraries](bt_static_screenshot_link_binary.gif)
    
5. Modify your build settings (`[Your App Target]` > `Build Settings`)
  - Update `Header Search Paths`
    - Add `$(PROJECT_DIR)/braintree_ios` (or whatever the name of the braintree folder at the top level of your project is)
    - Be sure to select recursive from the drop down at the right
    
    ![Screenshot of updating Header Search Paths](bt_static_screenshot_header_search_paths.png)
    
  - Update `Other Linker Flags`
    - Add `-ObjC`
    
    ![Screenshot of updating Header Search Paths](bt_static_screenshot_linker_flags.png)
    
6. Build and Run your app to test out the integration
7. [Integrate the SDK in your checkout form](https://developers.braintreepayments.com/ios/start/overview)
