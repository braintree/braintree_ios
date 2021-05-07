# Swift Package Manager Instructions

Support for Swift Package Manager was introduced in Braintree iOS v5. It requires Xcode 12.5+.

* [General Instructions](#general-instructions)
* [Binary Dependencies](#binary-dependencies)
* [BraintreeDataCollector](#braintreedatacollector)
* [BraintreeThreeDSecure](#braintreethreedsecure)

### General Instructions

To add the `Braintree` package to your Xcode project, select _File > Swift Packages > Add Package Dependency_ and enter `https://github.com/braintree/braintree_ios` as the repository URL. Tick the checkboxes for the specific Braintree libraries you wish to include.

If you look at your app target, you will see that the Braintree libraries you chose are automatically linked as a frameworks to your app (see _General > Frameworks, Libraries, and Embedded Content_).

In your app's source code files, use the following import syntax to include Braintree's libraries:
```
import BraintreeCore
import BraintreeCard
import BraintreeApplePay
import BraintreePayPal
```

### BraintreeThreeDSecure

#### Versions 5.3.0+

If you are using `BraintreeThreeDSecure`, you must also explicitly include `CardinalMobile` and `PPRiskMagnes`, both of which can be included through SPM.

If you were previously using versions 5.0.0 to 5.2.0 and you're upgrading to version 5.3.0 or above, you should delete `CardinalMobile.framework` from your project and remove the run script used to remove simulator slices before archiving (if applicable).

#### Versions 5.0.0 to 5.2.0

If you are using versions 5.0.0 to 5.2.0, include `BraintreeThreeDSecure` and `PPRiskMagnes` with Swift Package Manager. In addition, you must manually include `CardinalMobile.framework`. The following steps are required:

##### 1. Add CardinalMobile.framework

1. Once you've installed the Braintree Swift Package, find `CardinalMobile.framework` under the Frameworks directory in the Braintree package.
1. Right click on `CardinalMobile.framework` and select _Show in Finder_.
1. Drag and drop `CardinalMobile.framework` from Finder into your Xcode project
    * Select _Copy items if needed_.
    * Click _Finish_.
1. Open your project's settings by selecting your app target in the General tab
    * Under the _Frameworks, Libraries, and Embedded Content_ section, make sure `CardinalMobile.framework` is set to “Embed & Sign”
1. Go to the Build Phases tab. Under _Link Binary With Libraries_, make sure the framework is listed. This should happen automatically, but if not, add the framework manually via the `+` button.

##### 2. Remove simulator slices

CardinalMobile.framework contains architectures for both devices and simulators. When uploading to App Store Connect, Xcode will emit an error if the simulator slices have not been removed.

Option 1: Run the following command in the directory containing `CardinalMobile.framework` prior to archiving your app. You'll need to run this command each time you archive.

```sh
lipo -remove i386 -remove x86_64 -output CardinalMobile.framework/CardinalMobile CardinalMobile.framework/CardinalMobile
```

Option 2: Add the following run script to remove unneeded architectures.

```sh
FRAMEWORK="CardinalMobile"
# FRAMEWORK_EXECUTABLE_PATH is the path where Cardinal framework is located, check Cardinal framework path and update accordingly
FRAMEWORK_EXECUTABLE_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/$FRAMEWORK.framework/$FRAMEWORK"
EXTRACTED_ARCHS=()
for ARCH in $ARCHS
do
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
```

![image](image_assets/cardinal_run_script.png)
