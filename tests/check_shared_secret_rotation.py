#!/usr/bin/env python3
"""Check rendered core/CD/SRM secret consumers against their authentication peers.

Usage (requires PyYAML and prepared chart dependencies):
  helm template rotation-test src/harness --set global.cd.enabled=true \
    -f src/harness/override-secrets.yaml | python3 tests/check_shared_secret_rotation.py

No credential values are printed. This checks rendering, not runtime authentication.
"""
import sys

import yaml


def check(documents):
    resources = {(d['kind'], d['metadata']['name']): d for d in documents if d}
    errors = []
    references = {}
    configurations = {}
    for (kind, name), resource in resources.items():
        if kind not in ('Deployment', 'StatefulSet'):
            continue
        pod = resource['spec']['template']['spec']
        for container in (pod.get('containers') or []) + (pod.get('initContainers') or []):
            env = container.get('env') or []
            if len(env) != len({entry['name'] for entry in env}):
                errors.append(f'{name}/{container["name"]}: duplicate environment names')
            if container not in (pod.get('containers') or []):
                continue
            for entry in container.get('envFrom') or []:
                ref = entry.get('configMapRef')
                if ref:
                    data = resources.get(('ConfigMap', ref['name']), {}).get('data') or {}
                    configurations.update({(name, key): value for key, value in data.items()})
            for entry in env:
                ref = entry.get('valueFrom', {}).get('secretKeyRef')
                if ref:
                    references[name, entry['name']] = (ref['name'], ref['key'])
                if 'value' in entry:
                    configurations[name, entry['name']] = entry['value']

    # Each pair must read the same rotation unit, not independently generated keys.
    pairs = [
        (('gateway', 'JWT_SPLIT_SECRET'), ('harness-manager', 'jwtSplitSecret')),
        (('log-service', 'LOG_SERVICE_JWT_AUTH_SECRET'), ('platform-service', 'JWT_AUTH_SECRET')),
        (('log-service', 'LOG_SERVICE_PIPELINE_JWT_AUTH_SECRET'), ('pipeline-service', 'JWT_AUTH_SECRET')),
        (('log-service', 'LOG_SERVICE_MANAGER_JWT_AUTH_SECRET'), ('harness-manager', 'NEXT_GEN_MANAGER_SECRET')),
        (('access-control', 'OPA_SERVER_SECRET'), ('policy-mgmt', 'APP_INTERNAL_TOKEN_JWT_SECRET')),
        (('cv-nextgen', 'OPA_SERVER_SECRET'), ('policy-mgmt', 'APP_INTERNAL_TOKEN_JWT_SECRET')),
    ]
    for service in ('access-control', 'ng-manager', 'platform-service'):
        pairs.append(((service, 'GITOPS_SERVICE_SECRET'), ('gitops', 'IDENTITY_SERVICE_SECRET')))
    for service in ('ng-manager', 'pipeline-service', 'orchestration-engine', 'template-service'):
        pairs.append(((service, 'HSQS_AUTH_TOKEN'), ('queue-service', 'JWT_SECRET')))
    for service in ('ci-manager', 'iacm-manager'):
        if ('Deployment', service) in resources:
            pairs.append(((service, 'HSQS_AUTH_TOKEN'), ('queue-service', 'JWT_SECRET')))
    pairs.append((('harness-manager', 'QUEUE_SERVICE_AUTH_TOKEN'), ('queue-service', 'JWT_SECRET')))
    for service in ('harness-manager', 'ng-manager', 'pipeline-service', 'orchestration-engine'):
        pairs.append(((service, 'LOG_STREAMING_SERVICE_TOKEN'), ('log-service', 'LOG_SERVICE_GLOBAL_TOKEN')))
    pairs.append((('gateway', 'LOG_SVC_GLOBAL_TOKEN'), ('log-service', 'LOG_SERVICE_GLOBAL_TOKEN')))

    for client, receiver in pairs:
        label = f'{client[0]}.{client[1]} -> {receiver[0]}.{receiver[1]}'
        left, right = references.get(client), references.get(receiver)
        if left is None or right is None:
            errors.append(f'{label}: missing explicit Secret reference')
        elif left != right:
            errors.append(f'{label}: different rotation units')
        else:
            data = resources.get(('Secret', left[0]), {}).get('data') or {}
            if not data.get(left[1]):
                errors.append(f'{label}: referenced generated Secret key is missing or empty')

    if str(configurations.get(('log-service', 'LOG_SERVICE_DISABLE_AUTH'))).lower() != 'false':
        errors.append('log-service: LOG_SERVICE_DISABLE_AUTH must be false for the rotation overlay')
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print(f'PASS: {len(pairs)} authentication pairs, generated keys, duplicate-env check, and log authentication enabled')
    return 0


if __name__ == '__main__':
    sys.exit(check(list(yaml.safe_load_all(sys.stdin))))
