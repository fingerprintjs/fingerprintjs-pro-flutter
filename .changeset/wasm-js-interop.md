---
"fingerprintjs-pro-flutter": patch
---

Fix a Flutter web WASM crash when initializing the agent (`List<String>` is not a `JSArray`). Convert Dart string lists with `.toJS` before passing them to the JS agent.
