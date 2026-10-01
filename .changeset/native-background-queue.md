---
"fingerprint_flutter": patch
---

Android and iOS: create the native client and start `get` on a background thread, not the main thread. Creating the client at app startup no longer blocks the UI thread.
