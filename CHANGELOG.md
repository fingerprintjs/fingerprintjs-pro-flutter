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
