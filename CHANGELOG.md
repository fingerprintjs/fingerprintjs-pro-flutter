## [2.0.2-test.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v2.0.1...v2.0.2-test.1) (2023-09-22)


### Bug Fixes

* support Gradle 8 ([499a397](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/499a3975b2d895e09af89593fbb965c14499630f))

## [2.0.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v2.0.0...v2.0.1) (2023-09-07)


### Documentation

* **README:** add minimum OS versions ([e14fd70](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/e14fd70000a3cac21e1174134ddf2b287b250ff2))
* **README:** fingerprintJS Pro -> Fingerprint Pro ([3555881](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/35558812a89555fc41232583aab39bf902c14307))

## [2.0.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.7.0...v2.0.0) (2023-08-30)


### ⚠ BREAKING CHANGES

* remove wrong `errorMessage` field from `FingerprintJSProResponse`

### Features

* remove wrong `errorMessage` field from `FingerprintJSProResponse` ([6154081](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/6154081044fbc6d04f83faf7ade6a58f0301f36c))

## [1.7.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.6.0...v1.7.0) (2023-08-07)


### Features

* update Android agent to v2.3.2 ([dec191b](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/dec191b98b141675c4bf718c76b2702af4faaa4a))

## [1.6.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.5.0...v1.6.0) (2023-06-30)


### Features

* bump iOS Agent to v2.2.0 to introduce new Smart Signals INTER-46 ([882938b](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/882938b83c56276496df5ab456d44be2ca78b1c4))

## [1.5.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.4.1...v1.5.0) (2023-05-03)


### Features

* bump android to 2.3.1 ([7bd0f4a](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/7bd0f4af3d2be5e374bee2a3a4fa3240cbbfbc9e))
* update pubspec.lock ([7d86a88](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/7d86a8896064764fc7ece1fef67c6fd9a8ea44c1))

## [1.4.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.4.0...v1.4.1) (2023-05-03)


### Bug Fixes

* update Android agent to 2.3.0 ([f204bd0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/f204bd0bfcdb82ba9be95f7c4b2747c86a0d5aab))

## [1.4.1-test.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.4.0...v1.4.1-test.1) (2023-05-03)


### Bug Fixes

* update Android agent to 2.3.0 ([f204bd0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/f204bd0bfcdb82ba9be95f7c4b2747c86a0d5aab))

## [1.4.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.4.0...v1.4.1) (2023-05-03)


### Bug Fixes

* update Android agent to 2.3.0 ([f204bd0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/f204bd0bfcdb82ba9be95f7c4b2747c86a0d5aab))

## [1.4.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v1.4.0...v1.4.1) (2023-05-02)


### Bug Fixes

* update Android agent to 2.3.0 ([f204bd0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/f204bd0bfcdb82ba9be95f7c4b2747c86a0d5aab))

## 1.4.0

### New Features
* Add support for proxy integrations
* Add `scriptUrlPattern` param for web platform

### Bug Fixes
* Make all `IpLocation` fields nullable

## 1.4.0-dev.1

### New Features
* Added support for proxy integrations

## 1.3.0

### New Features
* Added support for web platform

### Bug Fixes
* Fix empty tag in methods `getVisitorId` and `getVisitorData` for web platform

## 1.2.3-dev.3

### Bug Fixes
* Fix js interop problems in dart2js environment

## 1.2.3-dev.2

### Bug Fixes
* Fix empty tag in methods `getVisitorId` and `getVisitorData` for web platform

## 1.2.3-dev.1

### New Features
* Added support for web platform 

## 1.2.2

### New Features
* Android agent updated to improve identification

## 1.2.1

### New Features
* iOS agent updated to allow request filtering

## 1.2.0

### New Features
* Now library support iOS 12 again. (Was broken in 1.1.0)

## 1.1.0

### New Features
* Update [iOS agent](https://dev.fingerprint.com/docs/ios) to the native, use 2.1.0 now
* Update [Android agent](https://dev.fingerprint.com/docs/native-android-integration) to the 2.1.1 version
* Add [tags](https://dev.fingerprint.com/docs/native-android-integration#tag-support-to-store-custom-data-with-each-identification) support
* Add [linkedId](https://dev.fingerprint.com/docs/native-android-integration#linked-id-support) support
* Add new method `getVisitorData` for result containing more data than `visitorId`
* Add `extendedResponseFormat` flag to the `initFpjs` function to get [extendedResponseFormat](https://dev.fingerprint.com/docs/native-android-integration#response-format) in the `getVisitorData` method

Now we have feature parity with the [JavaScript agent](https://dev.fingerprint.com/docs/js-agent).

## 1.0.4

### Documentation Changes
* Fix logo url

## 1.0.3

### Documentation Changes
* Update urls domain from fingerprintjs.com to fingerprint.com
* Update logo
* Add more code examples

## 1.0.2

### Documentation Changes
* Fix sample usage

## 1.0.1

### Documentation Changes
* Added contributing instructions
* Added badges

## 1.0.0

### New Features
* Supported Asian region (`ap`)

### Chores
* Updated fingerprintjs-pro-android to version 2.0
* Added ci test run
* Added codeowners

## 0.1.3

### Bug Fixes
* Fixed init method getting stuck in the native code

## 0.1.2

### Documentation Changes
* Added doc comments

## 0.1.1

### Chores
* Updated dependencies

## 0.1.0

* Initial implementation
