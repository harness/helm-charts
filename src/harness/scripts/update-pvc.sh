#!/bin/bash

# Parse arguments
NAMESPACE=""
OVERRIDEFILE=""
NEWSIZE=""
DATABASE=""
RELEASE=""
CHART=""

read -p "Enter Namespace: " NAMESPACE
read -p "Enter Override file path (eg: ./override-values.yaml): " OVERRIDEFILE
read -p "Enter new pvc size in Gi (eg: 30Gi): " NEWSIZE
read -p "Enter the required database name which requires size change (options are: mongodb, timescaledb, minio, postgresql, timescaledb-wal): " DATABASE
read -p "Enter release name: " RELEASE
read -p "Enter chart path/name/version (eg: harness/harness --version 0.x.y): " CHART 

# Check if yq is installed
if ! command -v yq &>/dev/null; then
    echo "Error: yq is not installed. Please install yq and try again."
    exit 1
fi

# Get the PVC name for the given database
echo "Fetching PVC for database: $DATABASE in namespace: $NAMESPACE"
if [ "$DATABASE" == "mongodb" ]; then
    PVC_NAME=$(kubectl get pvc -n "$NAMESPACE" -l app.kubernetes.io/name=mongodb -o jsonpath="{.items[*].metadata.name}")
elif [ "$DATABASE" == "postgresql" ]; then
    PVC_NAME=$(kubectl get pvc -n "$NAMESPACE" -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[*].metadata.name}")
elif [ "$DATABASE" == "minio" ]; then
    PVC_NAME=$(kubectl get pvc -n "$NAMESPACE" -l app.kubernetes.io/name=minio -o jsonpath="{.items[*].metadata.name}")
elif [ "$DATABASE" == "timescaledb" ]; then
    PVC_NAME=$(kubectl get pvc -n "$NAMESPACE" -l app=timescaledb-single-chart,purpose=data-directory -o jsonpath="{.items[*].metadata.name}")
elif [ "$DATABASE" == "timescaledb-wal" ]; then
    PVC_NAME=$(kubectl get pvc -n "$NAMESPACE" -l app=timescaledb-single-chart,purpose=wal-directory -o jsonpath="{.items[*].metadata.name}")
else
    echo "Error: unknown database"
    exit 1
fi

if [ -z "$PVC_NAME" ]; then
    echo "Error: No PVC found for database: $DATABASE in namespace: $NAMESPACE"
    exit 1
fi

echo "Found PVC: $PVC_NAME"

# Loop over the PVC names
for PVC in $PVC_NAME; do
    echo "Processing PVC: $PVC"
    # Patch the PVC to update its size
    echo "Patching PVC $PVC to new size $NEWSIZE"
    kubectl patch pvc "$PVC" -n "$NAMESPACE" --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/resources/requests/storage\", \"value\": \"$NEWSIZE\"}]"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to patch PVC $PVC"
        exit 1
    fi
done


# Update the override file using yq
echo "Updating override file: $OVERRIDEFILE with new size $NEWSIZE"
if [ "$DATABASE" == "mongodb" ]; then
    yq e -i ".platform.bootstrap.database.mongodb.persistence.size = \"$NEWSIZE\"" "$OVERRIDEFILE"
elif [ "$DATABASE" == "postgresql" ]; then
    yq e -i ".platform.bootstrap.database.postgresql.persistence.size = \"$NEWSIZE\"" "$OVERRIDEFILE"
elif [ "$DATABASE" == "minio" ]; then
    yq e -i ".platform.bootstrap.database.minio.persistence.size = \"$NEWSIZE\"" "$OVERRIDEFILE"
elif [ "$DATABASE" == "timescaledb" ]; then
    yq e -i ".platform.bootstrap.database.timescaledb.persistentVolumes.data.size = \"$NEWSIZE\"" "$OVERRIDEFILE"
elif [ "$DATABASE" == "timescaledb-wal" ]; then
    yq e -i ".platform.bootstrap.database.timescaledb.persistentVolumes.wal.size = \"$NEWSIZE\"" "$OVERRIDEFILE"
else
    echo "Error: unknown database"
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to update override file $OVERRIDEFILE"
    exit 1
fi


# Delete the StatefulSet associated with the database
echo "Deleting StatefulSet for database: $DATABASE in namespace: $NAMESPACE"

if [ "$DATABASE" == "mongodb" ]; then
    STATEFULSET_NAME=$(kubectl get statefulset -n "$NAMESPACE" -l app.kubernetes.io/name=mongodb -o jsonpath="{.items[0].metadata.name}")
elif [ "$DATABASE" == "postgresql" ]; then
    STATEFULSET_NAME=$(kubectl get statefulset -n "$NAMESPACE" -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}")
elif [ "$DATABASE" == "minio" ]; then
    STATEFULSET_NAME=$(kubectl get deployment -n "$NAMESPACE" -l app.kubernetes.io/name=minio -o jsonpath="{.items[0].metadata.name}")
elif [ "$DATABASE" == "timescaledb" ]; then
    STATEFULSET_NAME=$(kubectl get statefulset -n "$NAMESPACE" -l app=timescaledb-single-chart -o jsonpath="{.items[0].metadata.name}")
elif [ "$DATABASE" == "timescaledb-wal" ]; then
    STATEFULSET_NAME=$(kubectl get statefulset -n "$NAMESPACE" -l app=timescaledb-single-chart -o jsonpath="{.items[0].metadata.name}")
else
    echo "Error: unknown database"
    exit 1
fi

if [ -z "$STATEFULSET_NAME" ]; then
    echo "Error: No StatefulSet found for database: $DATABASE"
    exit 1
fi

if [ "$DATABASE" == "minio" ]; then
kubectl delete deployment "$STATEFULSET_NAME" -n "$NAMESPACE" --cascade=orphan
else
kubectl delete statefulset "$STATEFULSET_NAME" -n "$NAMESPACE" --cascade=orphan
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to delete StatefulSet $STATEFULSET_NAME"
    exit 1
fi

# Perform helm upgrade
echo "Performing helm upgrade for database: $DATABASE"
helm upgrade "$RELEASE" "$CHART" -f "$OVERRIDEFILE" -n "$NAMESPACE"

if [ $? -ne 0 ]; then
    echo "Error: Helm upgrade failed"
    exit 1
fi

echo "Helm upgrade completed successfully"
