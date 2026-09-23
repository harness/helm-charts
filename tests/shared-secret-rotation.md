# Core, CD and SRM shared-secret regression check

After preparing the umbrella chart dependencies, run with Python 3 and PyYAML:

```sh
set -o pipefail
helm template rotation-test src/harness \
  --set global.cd.enabled=true \
  -f src/harness/override-secrets.yaml |
  python3 tests/check_shared_secret_rotation.py
```

The checker compares rendered caller/receiver Secret references, verifies that the
shared generator emits the referenced keys, checks duplicate environment names,
and requires log authentication to be enabled. It prints no credential values.
Changing a caller to a different generated key, omitting an environment variable,
or restoring the chart's auth-disabled log setting makes the check fail.

This check covers core platform, CD, and the SRM charts enabled by CD. It does not
prove image startup bindings or endpoint authentication. Runtime validation must
also accept new credentials and reject previous, stock, and wrong credentials.
When CI or IaCM is enabled in the render, their queue clients are checked too.
The image-level IRO/monitoring hooks and SRM schema `cv`/`srm` path mismatch need
separate application fixes; changing Helm mappings cannot add those image hooks.
