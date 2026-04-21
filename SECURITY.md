# Security Policy

This repository adheres to the [PayPal Vulnerability Reporting Policy](https://hackerone.com/paypal).

## Reporting a Vulnerability

If you think you have found a vulnerability in this repository, please report it to us through coordinated disclosure.

**Please do not report security vulnerabilities through public issues, discussions, or pull requests.**

Instead, report it using one of the following ways:

* Email the PayPal Security Team at [security@paypal.com](mailto:security@paypal.com)
* Submit through the [PayPal Bug Bounty Program](https://hackerone.com/paypal) on HackerOne
* Report a [vulnerability](https://github.com/braintree/braintree_ios/security/advisories/new) directly via private vulnerability reporting on GitHub

Please include the following in your report:

* The type of issue and affected version(s)
* Step-by-step instructions to reproduce the issue
* Impact of the issue and how an attacker might exploit it

## Supported Versions

### New Features

New features are only added to the latest major release and will not be backported to older versions.

### Bug Fixes

Only the latest release series receives bug fixes. When enough bugs are fixed and a new release is warranted, it is cut from the main branch.

### Security Issues

Only the latest release series receives patches and new versions in the case of a security issue.

### Severe Security Issues

For severe security issues, we will provide new versions as above. Additionally, the last major release series may receive patches at our discretion. Severity classification is determined by the Braintree SDK team.

### Unsupported Release Series

When a release series is no longer supported, it is your responsibility to manage bugs and security issues. If you are not comfortable maintaining your own versions, we strongly recommend upgrading to a supported release.

### Platform Support

| Platform | Supported Versions      |
| -------- | ----------------------- |
| iOS      | Latest 2 major versions |

## Disclosure Policy

We are committed to working with security researchers in good faith. To support responsible disclosure, our team will:

- Acknowledge your report within **2 business days**
- Provide a triage update within **5 business days**
- Keep you informed of our progress toward a fix
- Notify you before any public disclosure

We ask that you:

- Do not publicly disclose the issue before it has been resolved
- Avoid accessing, modifying, or deleting data that does not belong to you
- Make a good faith effort to avoid disruption to production systems

We appreciate responsible disclosure and your efforts to keep Braintree SDK users safe.
