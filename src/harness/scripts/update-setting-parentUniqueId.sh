if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

namespace="$1"


MONGO_PASS=$(kubectl get secret -n $namespace mongodb-replicaset-chart -o jsonpath={.data.mongodb-root-password} | base64 --decode)
kubectl exec -it mongodb-replicaset-chart-0 -n $namespace -- mongo <<EOF
use admin
db.auth('admin', '${MONGO_PASS}')
use ng-harness
db.settings.dropIndex("accountIdentifier_parentUniqueId_identifier_userId_unique_idx");
db.settings.dropIndex("uniqueId_1");
db.settings.updateMany({ }, { \$unset: { "uniqueId": "", "parentUniqueId": "" } });
db.uniqueIdParentIdMigrationStatus.deleteOne({ "entityClassName" : "NGSetting"});
EOF
kubectl rollout restart deployment ng-manager -n $namespace
