#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
# pass 2 file names to this script, it will yield a output
#./migrate-values-0.9.x.sh -f <override.yaml>
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
while getopts ":f:c:" opt; do
  case ${opt} in
    f )
      overrideFile=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      echo "use ./migrate-0.9.x.sh -f <override.yaml>  "
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if command -v yq &>/dev/null; then
    echo "yq is installed."
else
    echo " yq is not installed."
    echo "\n For linux system, Run the following: \n ------------------- \n wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq \n ------------------- "
    echo "\n For Windows system, Run the following: \n ------------------- \n choco install yq \n ------------------- "
    echo "\n For other system and information, visit : \n ------------------- \n https://github.com/mikefarah/yq \n ------------------- "
fi

old_file=$overrideFile

filename=$(basename "$old_file")
extension="${filename##*.}"  # Get the extension
filename_without_extension="${filename%.*}"  # Remove the extension
new_extension="new"
new_file_name="${filename_without_extension}-${new_extension}.${extension}"

echo "Original File Name: $filename"
echo "New File Name: $new_file_name"

# Get the directory path of the old file
dir_path="$(dirname "$old_file")"
newOverrideFile=$dir_path/$new_file_name
# Check if the old file exists
if [ -f "$old_file" ]; then

    # Read content from the old file
    old_content=$(<"$old_file")

    # Check if the directory path is valid
    if [ -d "$dir_path" ]; then
        # Create the new file with the content of the old file
        echo "$old_content" > "$newOverrideFile"
        echo "Content copied from $old_file to $new_file_name in $dir_path"
    else
        echo "Invalid directory path: $dir_path"
    fi
else
    echo "$old_file does not exist."
fi

#What Changed?
# Restructuring of harness components for better packaging and modularization.

# # platform
# - mongo moved from platform.mongo to platform.boostrap.database.mongo
yq eval '(select(has("platform") and .platform | has("mongodb")) | .platform.bootstrap.database.mongodb = .platform.mongodb | del(.platform.mongodb)) // .' -i "$newOverrideFile"
echo "Moved platform.mongodb to platform.bootstrap.database.mongodb in $newOverrideFile"
# - timescaledb moved from platform.timescaledb to platform.boostrap.database.timescaledb
yq eval '(select(has("platform") and .platform | has("timescaledb")) | .platform.bootstrap.database.timescaledb = .platform.timescaledb | del(.platform.timescaledb)) // .' -i "$newOverrideFile"
echo "Moved platform.timescaledb to platform.bootstrap.database.timescaledb in $newOverrideFile"
# - minio moved from platform.minio to platform.boostrap.database.minio
yq eval '(select(has("platform") and .platform | has("minio")) | .platform.bootstrap.database.minio = .platform.minio | del(.platform.minio)) // .' -i "$newOverrideFile"
echo "Moved platform.minio to platform.bootstrap.database.minio in $newOverrideFile"
# - redis moved from platform.redis to platform.boostrap.database.redis
yq eval '(select(has("platform") and .platform | has("redis")) | .platform.bootstrap.database.redis = .platform.redis | del(.platform.redis)) // .' -i "$newOverrideFile"
echo "Moved platform.redis to platform.bootstrap.database.redis in $newOverrideFile"
# - postgresql moved from infra.postgresql to platform.boostrap.database.postgresql
yq eval '(select(has("infra") and .infra | has("postgresql")) | .platform.bootstrap.database.postgresql = .infra.postgresql | del(.infra)) // .' -i "$newOverrideFile"
echo "Moved infra.postgresql to platform.bootstrap.database.postgresql in $newOverrideFile"
# - clickhouse moved from ccm.clickhouse to platform.boostrap.database.clickhouse
yq eval '(select(has("ccm") and .ccm | has("clickhouse")) | .platform.bootstrap.database.clickhouse = .ccm.clickhouse ) // .' -i "$newOverrideFile"
echo "Moved ccm.clickhouse to platform.bootstrap.database.clickhouse in $newOverrideFile"
# - clickhouse enabled moved to global flag. earlier ccm.clickhouse.enabled converted to global.database.clickhouse.enabled
yq eval '(select(has("ccm") and .ccm | has("clickhouse")) | .global.database.clickhouse = .ccm.clickhouse | del(.ccm.clickhouse)) // .' -i "$newOverrideFile"
echo "Moved ccm.clickhouse to global.database.clickhouse in $newOverrideFile"
yq eval 'del(.ccm.nextgen-ce.clickhouse)' -i "$newOverrideFile"
yq eval 'del(.ccm.batch-processing.clickhouse)' -i "$newOverrideFile"
echo "Moved ccm.clickhouse to global.database.clickhouse in $newOverrideFile"
# - move secrets from platform.secrets to platform.bootstrap.secrets
yq eval '(select(has("platform") and .platform | has("harness-secrets")) | .platform.bootstrap.harness-secrets = .platform.harness-secrets | del(.platform.harness-secrets)) // .' -i "$newOverrideFile"
echo "Moved platform.harness-secrets to platform.bootstrap.harness-secrets in $newOverrideFile"
# - move rbac/service-account from platform.harness-manager to platform.bootstrap.rbac
echo "No change required for bootstrap/rbac chart in $newOverrideFile"
# - move global.ingress.nginx to platform.bootstrap.networking.nginx
yq eval '(select( .global | has("ingress") and .global.ingress | has("nginx")) | .platform.bootstrap.networking.nginx = .global.ingress.nginx | del(.global.ingress.nginx)) // .' -i "$newOverrideFile"
echo "Moved global.ingress.nginx to platform.bootstrap.networking.nginx in $newOverrideFile"
# - move global.ingress.nginx to platform.bootstrap.networking.nginx
yq eval '(select( .global | has("ingress") and .global.ingress | has("defaultbackend")) | .platform.bootstrap.networking.defaultbackend = .global.ingress.defaultbackend | del(.global.ingress.defaultbackend)) // .' -i "$newOverrideFile"
echo "Moved global.ingress.defaultbackend to platform.bootstrap.networking.defaultbackend in $newOverrideFile"
# - move global.istio.gateway to platform.bootstrap.networking.istio
echo "No changes required for istio/gateway file in $newOverrideFile"
# - move cv-nextgen, verification, learning-engine, le-nextgen from platform.* to srm.*
yq eval '(select(has("platform") and .platform | has("cv-nextgen")) | .srm.cv-nextgen = .platform.cv-nextgen | del(.platform.cv-nextgen)) // .' -i "$newOverrideFile"
echo "Moved platform.cv-nextgen to srm.cv-nextgen in $newOverrideFile"
yq eval '(select(has("platform") and .platform | has("verification-svc")) | .srm.verification-svc = .platform.verification-svc | del(.platform.verification-svc)) // .' -i "$newOverrideFile"
echo "Moved platform.verification-svc to srm.verification-svc in $newOverrideFile"
yq eval '(select(has("platform") and .platform | has("le-nextgen")) | .srm.le-nextgen = .platform.le-nextgen | del(.platform.le-nextgen)) // .' -i "$newOverrideFile"
echo "Moved platform.le-nextgen to srm.le-nextgen in $newOverrideFile"
yq eval '(select(has("platform") and .platform | has("learning-engine")) | .srm.learning-engine = .platform.learning-engine | del(.platform.learning-engine)) // .' -i "$newOverrideFile"
echo "Moved platform.learning-engine to srm.learning-engine in $newOverrideFile"
# - move ti-service from platform.ti-service.* to ci.ti-service.*
yq eval '(select(has("platform") and .platform | has("ti-service")) | .ci.ti-service = .platform.ti-service | del(.platform.ti-service)) // .' -i "$newOverrideFile"
echo "Moved platform.ti-service to ci.ti-service in $newOverrideFile"
# - move policy-mgmt.* into platform.policy-mgmt.*
yq eval '(select(has("policy-mgmt")) | .platform.policy-mgmt = .policy-mgmt | del(.policy-mgmt)) // .' -i "$newOverrideFile"
echo "Moved policy-mgmt to platform.policy-mgmt in $newOverrideFile"
# - moved dashboards.* to platform.*
yq eval '(select(has("ngcustomdashboard") and .ngcustomdashboard | has("ng-custom-dashboards")) | .platform.ng-custom-dashboards = .ngcustomdashboard.ng-custom-dashboards) // .' -i "$newOverrideFile"
yq eval '(select(has("ngcustomdashboard") and .ngcustomdashboard | has("looker")) | .platform.looker = .ngcustomdashboard.looker | del(.ngcustomdashboard)) // .' -i "$newOverrideFile"
echo "Moved dashboards to platform in $newOverrideFile"
yq eval 'del(.ng-manager)' -i "$newOverrideFile"

# # ccm
# - clickhouse moved from ccm.clickhouse to platform.boostrap.database.clickhouse
#done
# - clickhouse enabled moved to global flag. earlier ccm.clickhouse.enabled converted to global.database.clickhouse.enabled
#done

# # cd
# - created a seperate chart to consists only gitops.
# - move gitops.* to cd.gitops.*
yq eval '(select(has("gitops")) | .cd.gitops = .gitops | del(.gitops)) // .' -i "$newOverrideFile"
echo "Moved gitops to cd.gitops in $newOverrideFile"

# # cet
# - no changes since 0.8.x , however 0.7.x cet charts moved from srm.* to cet.*. Added harmless redundant yq conditions
yq eval '(select(has("srm") and .srm | has("enable-receivers")) | .cet.enable-receivers = .srm.enable-receivers | del(.srm.enable-receivers)) // .' -i "$newOverrideFile"
echo "Moved srm.enable-receivers to cet.enable-receivers in $newOverrideFile"
yq eval '(select(has("srm") and .srm | has("et-service")) | .cet.et-service = .srm.et-service | del(.srm.et-service)) // .' -i "$newOverrideFile"
echo "Moved srm.et-service to cet.et-service in $newOverrideFile"
yq eval '(select(has("srm") and .srm | has("et-collector")) | .cet.et-collector = .srm.et-collector | del(.srm.et-collector)) // .' -i "$newOverrideFile"
echo "Moved srm.et-collectorto cet.et-collector in $newOverrideFile"
yq eval '(select(has("srm") and .srm | has("et-receiver-decompile")) | .cet.et-receiver-decompile = .srm.et-receiver-decompile | del(.srm.et-receiver-decompile)) // .' -i "$newOverrideFile"
echo "Moved srm.et-receiver-decompile to cet.et-receiver-decompile in $newOverrideFile"
yq eval '(select(has("srm") and .srm | has("et-receiver-hit")) | .cet.et-receiver-hit = .srm.et-receiver-hit | del(.srm.et-receiver-hit)) // .' -i "$newOverrideFile"
echo "Moved srm.et-receiver-hit to cet.et-receiver-hit in $newOverrideFile"
yq eval '(select(has("srm") and .srm | has("et-receiver-sql ")) | .cet.et-receiver-sql = .srm.et-receiver-sql | del(.srm.et-receiver-sql)) // .' -i "$newOverrideFile"
echo "Moved srm.et-receiver-sql to cet.et-receiver-sql in $newOverrideFile"
yq eval '(select(has("srm") and .srm | has("et-receiver-agent")) | .cet.et-receiver-agent = .srm.et-receiver-agent | del(.srm.et-receiver-agent)) // .' -i "$newOverrideFile"
echo "Moved srm.et-receiver-agent to cet.et-receiver-agent in $newOverrideFile"
# # chaos
# - no changes

# # ci
# - move ti-service from platform.* to ci.*
# done

# # dashboards
# - restructured. Part of platform
# - moved dashboards.* to platform.*
# done

# # ff
# - no changes

# # gitops
# - restructured.
# - move gitops.* to cd.gitops.*
# done

# # policy-mgmt
# - restructured.
# - move policy-mgmt.* into platform.policy-mgmt.*
# done

# # srm
# - new chart directory all together.
# - move cv-nextgen, verification, learning-engine, le-nextgen from platform.* to srm.*
# done

# # sto
# - no changes

yq eval -i 'sortKeys(..)' $newOverrideFile