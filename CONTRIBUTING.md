# Contribute

Thanks for considering contributing to this project. Ways you can help:

* Create a pull request
* Add an issue
* [Contact us](README.md#feedback) with feedback

## Development

Clone this repo, then install the project's development dependencies:

```
gem install bundler
bundle install
```

This installs [CocoaPods](http://cocoapods.org/), which you can then use to obtain all the iOS dependencies:

```
pod install
```

## Environments

The architecture of the Client API means that you'll need to develop against a merchant server when developing braintree-ios. The merchant server uses a server side client library such as [`braintree_ruby`](https://github.com/braintree/braintree_ruby) to coordinate with a particular Braintree Gateway environment. The various Gateway environments, such as `development`, `sandbox` and `production`, in turn determine the specific behaviors around merchant accounts, credit cards, PayPal, etc.


## Tests

Use [Rake](http://rake.rubyforge.org/) to run tests, generate docs, and create releases. To view available rake tasks:

```
rake -T
```
