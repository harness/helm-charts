if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <namespace> <accountId> <subdomainUrl>"
    exit 1
fi

# Assign the first argument to namespace
namespace="$1"

# Assign the second argument to accountId
accountId="$2"

# Assign the second argument to subdomainUrl
subdomainUrl="$3"

MONGO_PASS=$(kubectl get secret -n $namespace mongodb-replicaset-chart -o jsonpath={.data.mongodb-root-password} | base64 --decode)
kubectl exec -it mongodb-replicaset-chart-0 -n $namespace -- mongosh <<EOF
use admin
db.auth('admin', '${MONGO_PASS}')
use gateway
db.account_refs.update({"uuid":"${accountId}"},{\$set:{"subdomainUrl": "${subdomainUrl}"}})
db.account_refs.find()
use harness
db.accounts.update({"_id":"${accountId}"},{\$set:{"subdomainUrl": "${subdomainUrl}"}})
db.accounts.find()
EOF
kubectl patch configmap ng-auth-ui -n $namespace --type merge -p '{"data":{"EXPECTED_HOSTNAME":"app.harness.io"}}'
kubectl rollout restart -n $namespace deployment -l "app.kubernetes.io/name=ng-auth-ui"
