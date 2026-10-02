---
"fingerprint_flutter": patch
---

The `Fingerprint` constructor throws `ArgumentError` for an `endpoints` entry that is not an `http` or `https` URL. Before, it failed at `get`, differently on each platform.
