## [4.3.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v4.2.0...v4.3.0) (2025-09-23)


### Features

* add Proximity Detection init options (`allowUseOfLocationData` - to allow collect location data and `locationTimeoutMillisAndroid` - to configure the location retrieval timeout on Android ([227d4c1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/227d4c14b39c59039b44b9a85620fd6829baeca5))



### Supported Native SDK Version Range

* Fingerprint Android SDK Version Range: **`>= 2.10.0 and < 2.11.0`**
* Fingerprint iOS SDK Version Range: **`>= 2.10.0 and < 2.11.0`**

## [4.2.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v4.1.0...v4.2.0) (2025-09-08)


### Features

* use Fingerprint Pro Android v2.10.0 ([ef9e8fa](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/ef9e8fae9b9bab6d2d903bfc762a615778c0c7d8))
* use Fingerprint Pro iOS v2.10.0 ([bd0ae3b](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/bd0ae3b7883ca0dc1198a3638e235786fded82e0))



### Supported Native SDK Version Range

* Fingerprint Android SDK Version Range: **`>= 2.10.0 and < 2.11.0`**
* Fingerprint iOS SDK Version Range: **`>= 2.10.0 and < 2.11.0`**

## [4.1.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v4.0.1...v4.1.0) (2025-08-25)


### Features

* add `ProxyIntegrationSecretEnvironmentMismatch` error ([f095967](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/f095967a45e13092693c991e5302d9cc824bfcb6))
* add error handling for invalid proxy integration headers and secret ([02b921e](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/02b921ebb4f168250da3084895a4395425230797))
* use Fingerprint Pro Android v2.9.0 ([66c3525](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/66c352573763839c0d262269dc5321c2f7de7a3f))
* use Fingerprint Pro iOS v2.9.0 ([1f5daf9](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/1f5daf9159c86ba257d814851c87ef287769ff49))
* use Fingerprint Pro JSAgent loader v3.11.13 ([6cf7efc](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/6cf7efc6ca4512877ede3792bc5261d34cc4c34b))



### Supported Native SDK Version Range

* Fingerprint Android SDK Version Range: **`>= 2.9.0 and < 2.10.0`**
* Fingerprint iOS SDK Version Range: **`>= 2.9.0 and < 2.10.0`**

## [4.0.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v4.0.0...v4.0.1) (2025-06-26)


### Bug Fixes

* add flutter.sdk path to the local.properties before running semantic release info ([a4a681e](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/a4a681e1072cddf5b49ab1b45b65d181202eb505))
* pin Fingerprint native dependencies to MINOR version instead of MAJOR ([01070b2](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/01070b2c16fd09aff5ce02832fcdd5c0b4d04c58))



### Supported Native SDK Version Range

* Fingerprint Android SDK Version Range: **`>= 2.8.0 and < 2.9.0`**
* Fingerprint iOS SDK Version Range: **`>= 2.8.2 and < 2.9.0`**

## [4.0.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.3.2...v4.0.0) (2025-05-06)


### ⚠ BREAKING CHANGES

* Flutter sdk minimal version is 3.13.0
* Dart sdk minimal version is 3.3.0

### Features

* update required Dart sdk minimal version to 3.3.0 ([a968392](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/a968392bac170911c19259d42b207e91a1b7df34))
* update required Flutter sdk minimal version to 3.13.0 ([1441f65](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/1441f65ec269c308038fc68c235aa47451dc6c30))


### Bug Fixes

* migrate from `dart:js_utils` and `package:js` to `dart:js_interop` for Web platform ([2d2a068](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/2d2a068c806b721fe329949bd8f547ec4982d87e))
* remove `js` package from dependencies ([45f46bf](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/45f46bf8e590fc277f2772364f2371265c88f2cc))
* use declarative Gradle plugin syntax ([8396f4e](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/8396f4e4d08c2f12828f1e7cfe1f896a29f87d85))



### Supported Native SDK Version Range

* Fingerprint Android SDK Version Range: **`>= 2.7.0 and < 3.0.0`**
* Fingerprint iOS SDK Version Range: **`>= 2.7.0 and < 3.0.0`**

## [3.3.2](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.3.1...v3.3.2) (2024-12-09)


### Documentation

* **README:** add how to specify a custom timeout block ([66fb0bd](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/66fb0bd615a13245418d4101e8ced1c95d32e9c9))

## [3.3.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.3.0...v3.3.1) (2024-12-05)


### Bug Fixes

* make integration info name consistent through all platforms ([8128cf4](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/8128cf474166d44c7fe3540f732f86bbbf3cc291))

## [3.3.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.2.0...v3.3.0) (2024-12-03)


### Features

* add `sealedResult` support ([5dec0bf](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/5dec0bf9893976bbe3c62ad41863dd7cec84c3fc))
* add `timeoutMs` argument for `getVisitorId` and `getVisitorData` methods ([822504a](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/822504aadc140f180bcb60188f841af4dff1e06c))
* use Fingerprint Pro Android v2.7.0 ([d2f24f2](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/d2f24f20a7758953e88f416d24cf880be66dfa7b))
* use Fingerprint Pro iOS v2.7.0 ([7144b0a](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/7144b0ada6cd466d63670c1403da192ed38b3246))
* use Fingerprint Pro JSAgent loader v3.11.3 ([b789fb0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/b789fb01c36978f2d51cab507b652f7cabb5b3a7))


### Bug Fixes

* fix JSAgent issue with empty `ipLocation` ([ae53e8b](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/ae53e8b0f58995383f2cb852e93e0cf72bf32cdf))

## [3.2.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.1.0...v3.2.0) (2024-10-08)


### Features

* use Fingerprint Pro Android v2.6.0 ([c3544b1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/c3544b1c45f2f6ea55231a29da52db366e5410b0))

## [3.1.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.0.1...v3.1.0) (2024-08-22)


### Features

* add `endpointFallbacks` configuration param ([aeae143](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/aeae143c807fe1ce736172501b1c15cc9f13a81c))
* add `scriptUrlPatternFallbacks` configuration param ([ae44e86](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/ae44e86f3ebbd383250e7a24b8be69355ec59fb3))
* update Android agent to v2.5.0 ([fd94c3a](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/fd94c3a0632f6ebda18405bb4775c4cb0d70f007))
* update iOS agent to v2.6.0 ([f6627a2](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/f6627a23e7c667249c6d995b60b24308be707a9a))

## [3.0.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v3.0.0...v3.0.1) (2024-08-06)


### Bug Fixes

* don't crash on empty `ipLocation` field for new subs ([1b8a657](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/1b8a6573473215385d24461e19e9f3b6bf084632))


### Documentation

* **README:** fix links formatting ([c7c2862](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/c7c2862f0358ca02cc28274696dc582b1fee1c88))
* **README:** unify linkedId section ([9339040](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/9339040312decaf6cc8a3062fd2e16ac0047e0b2))

## [3.0.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v2.1.1...v3.0.0) (2024-03-25)


### ⚠ BREAKING CHANGES

* sdk minimal version required to use this library is now 3.1.0+

### Features

* update dependencies ([1e7393e](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/1e7393e74524a75e9fb242b265d4fbcc9c104e7e))
* update Fingerprint PRO for android to 2.4.0 ([ea092b1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/ea092b1870aa36a0b9d25364ebeabc4010844ac7))
* update Fingerprint PRO for iOS to 2.4.0 ([d3a016a](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/d3a016a3e5d8632f65fdcde430cb24dc1560254d))
* update required sdk minimal version to 3.1.0+ ([75c1e08](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/75c1e08343d0029646ab7b691b0a246cb2d5d6a0))


### Bug Fixes

* change sdk limitations ([b48231c](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/b48231c57e37509fc9668560d667aa8dd5e83a97))

## [2.1.1](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v2.1.0...v2.1.1) (2024-01-19)


### Bug Fixes

* add TooManyRequestError for web platform ([219467f](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/219467f1b310a655f4e80091d7e0c949ffc645fe))
* improve error reporting for web platform ([df3739c](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/df3739c147a9e1e1f9e98604848a50754326c282))

## [2.1.0](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v2.0.2...v2.1.0) (2023-11-15)


### Features

* bump gradle plugin for example ([0c83a57](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/0c83a57cb9a2748926f174e40617d4282086cf80))
* update Android agent to 2.3.4 ([0322065](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/03220654a62f76d465f0fbf6a93f7a75da2be5f8))
* update iOS agent to 2.3.1 ([459c7ff](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/commit/459c7ffb475787ca4fc8e2971242c8b23e48b497))

## [2.0.2](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/compare/v2.0.1...v2.0.2) (2023-09-25)


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
