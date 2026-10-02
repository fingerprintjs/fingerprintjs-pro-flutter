---
"fingerprint_flutter": patch
---

The `Fingerprint` constructor throws `ArgumentError` for an `endpoints` entry that is not an absolute `http` or `https` URL, such as one without a scheme. Before, these failed only at `get`, with a different error on each platform.
