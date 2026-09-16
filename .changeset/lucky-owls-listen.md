---
"fingerprintjs-pro-flutter": patch
---

Route all calls through a `plugin_platform_interface` implementation: `MethodChannelFingerprint` for Android and iOS, `FingerprintWeb` for the web. The web implementation no longer answers its own method channel. `FpjsProPlugin.channelName` moved to `MethodChannelFingerprint.channelName`.
