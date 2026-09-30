---
"fingerprint_flutter": patch
---

Android: when the native SDK throws during `get`, it now fails with `unknown_error` and the SDK's message. Before, JVM errors crashed the app and other throws lost the message.
