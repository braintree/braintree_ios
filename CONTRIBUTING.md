# Contribute

Thanks for considering contributing to this project. Ways you can help:

* [Create a pull request](https://help.github.com/articles/creating-a-pull-request)
* [Add an issue](https://github.com/braintree/braintree_ios/issues)
* [Contact us](README.md#feedback) with feedback

__Note on Translations:__ We cannot accept language translation requests. We support the same [languages that are supported by PayPal](https://developer.paypal.com/docs/api/reference/locale-codes/) and have a dedicated localization team to provide the translations.

## Development

Clone this repo and ensure you have [CocoaPods](http://cocoapods.org/) version 1.11.3 installed to run the project. If you have CocoaPods installed but are unsure of the version, you can run the following:
```
pod --version
```


Once you've installed CocoaPods you can install the project's development dependencies:

```
pod install
```

Read our [development guidelines](DEVELOPMENT.md) to get a sense of how we think about working on this codebase.

## Environments

The architecture of the Client API means that you'll need to develop against a merchant server when developing braintree-ios. The merchant server uses a server side client library such as [`braintree_ruby`](https://github.com/braintree/braintree_ruby) to coordinate with a particular Braintree Gateway environment. The various Gateway environments, such as `development`, `sandbox` and `production`, in turn determine the specific behaviors around merchant accounts, credit cards, PayPal, etc.
