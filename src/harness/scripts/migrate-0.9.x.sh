#!/bin/bash
# pass 2 file names to this script, it will yield a output
#./migrate-0.9.x.sh -f <override.yaml>
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
new_file_name="newOverride.yaml"
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
yq eval '.platform.bootstrap.database.mongodb = .platform.mongodb | del(.platform.mongodb)' -i "$newOverrideFile"
echo "Moved platform.mongodb to platform.bootstrap.database.mongodb in $newOverrideFile"
# - timescaledb moved from platform.timescaledb to platform.boostrap.database.timescaledb
# - minio moved from platform.timescaledb to platform.boostrap.database.minio
# - postgresql moved from infra.postgresql to platform.boostrap.database.postgresql
# - clickhouse moved from ccm.clickhouse to platform.boostrap.database.clickhouse
# - clickhouse enabled moved to global flag. earlier ccm.clickhouse.enabled converted to global.database.clickhouse.enabled
# - move secrets from platform.secrets to platform.bootstrap.secrets
# - move rbac/service-account from platform.harness-manager to platform.bootstrap.rbac
# - move global.ingress.nginx to platform.bootstrap.networking.nginx ? -> not done, also resources change is missing.
# - move global.istio.gateway to platform.bootstrap.networking.istio ? -> not done
# - move cv-nextgen, verification, learning-engine, le-nextgen from platform.* to srm.*
# - move ti-service from platform.ti-service.* to ci.ti-service.*
# - move policy-mgmt.* into platform.policy-mgmt.*
# - moved dashboards.* to platform.*

# # ccm
# - clickhouse moved from ccm.clickhouse to platform.boostrap.database.clickhouse
# - clickhouse enabled moved to global flag. earlier ccm.clickhouse.enabled converted to global.database.clickhouse.enabled

# # cd
# - created a seperate chart to consists only gitops.
# - move gitops.* to cd.gitops.*

# # cet
# - no changes since 0.8.x , however 0.7.x cet charts moved from srm.* to cet.*. Added harmless redundant yq conditions

# # chaos
# - no changes

# # ci
# - move ti-service from platform.* to ci.*

# # dashboards
# - restructured. Part of platform
# - moved dashboards.* to platform.*

# # ff
# - no changes

# # gitops
# - restructured.
# - move gitops.* to cd.gitops.*

# # policy-mgmt
# - restructured.
# - move policy-mgmt.* into platform.policy-mgmt.*

# # srm
# - new chart directory all together.
# - move cv-nextgen, verification, learning-engine, le-nextgen from platform.* to srm.*

# # sto
# - no changes