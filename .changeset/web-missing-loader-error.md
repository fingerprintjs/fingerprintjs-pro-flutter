---
"fingerprint_flutter": patch
---

Web: if the loader `<script>` tag is missing from `web/index.html`, `get` throws `script_load_fail` with a message naming the tag, instead of `unknown_error` with a JS `TypeError`.
