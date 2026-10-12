# Module values

Each module's `values.yaml` holds Harness-internal defaults. Customer-facing settings live in `src/harness/values.yaml`.
Customers always override with the umbrella path (`platform.ng-manager.x`); a module file uses the path inside the module (`ng-manager.x`).
The umbrella wins when both set a value, so moving a default between the two files never changes the rendered result.

## Where does a new value go?

Take the first "yes":

1. Does it differ per environment, or would support tell a customer to change it (hosts, storage, registry, proxy, resources, scheduling, enable flags)? Put it in the umbrella `values.yaml` with a `# --` doc line.
2. Is it the same for every customer, and would changing it break or unsupport the install (`ENV`, `RHS_ENABLED`, service-to-service URLs, Kafka/TLS wiring, ingress routes, image pins, secret mappings)? Put it in the module `values.yaml`.
3. Unsure? Put it in the module, without a doc line.

## Shared secrets

`smpSharedKubernetesSecrets` maps `<ENV_VAR>: <key in harness-shared-secrets>`. Env vars sharing a key share a value.

- Reuse the key the same env var uses in the prod/qa overrides. Find existing mappings with `rg <ENV_VAR> src/modules/*/values.yaml`.
- The key must exist in the key list in `src/harness/templates/harness-shared-secrets.yaml`.
- Mappings apply only when `global.sharedSecrets.enabled=true`.
- `unified-data-platform` uses `secretKeyRef` and is not gated by the flag. It requires `global.sharedSecrets.enabled=true`.
