#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Migrates values.yaml/override.yaml to follow the new module structuring
# Pass -f option with values.yaml/override.yaml file and it will yield an yaml file with its fields restructured
#./migrate-values-0.9.x.sh -f <override.yaml>
USAGE="Usage: $0 [-f <override-file.yaml>]"

# Parse options
overrideFile=""
while getopts ":f:" opt; do
  case ${opt} in
  f)
    overrideFile=$OPTARG
    ;;
  \?)
    echo "Invalid option: -$OPTARG" 1>&2
    echo $USAGE
    exit 1
    ;;
  :)
    echo "Option: -$OPTARG requires an argument" 1>&2
    echo $USAGE
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [ -z "$overrideFile" ]; then
  echo "Error: -f <override-file.yaml> option is required." 1>&2
  echo $USAGE
  exit 1
fi

# Check if yq is installed
if command -v yq &>/dev/null; then
  echo -e "\nyq is already installed."
else
  echo "Error: yq tool is not installed."
  echo "Please install yq before running this script."

  echo -e "\n***** Instructions to Install yq *****"
  echo -e "\n For linux system, Run the following:"
  echo "wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq"

  echo -e "\n For Windows system, Run the following:"
  echo "choco install yq"

  echo -e "\n For other system and information, visit : https://github.com/mikefarah/yq"
  echo -e "**************************************\n"
  exit 1
fi

required_yq_version="4.35.0"
installed_yq_version=$(yq --version | cut -d ' ' -f 4 | sed 's/v//')

# Compare versions
if [[ "$(printf '%s\n' "$required_yq_version" "$installed_yq_version" | sort -V | head -n1)" != "$required_yq_version" ]]; then
    echo "ERROR: yq version $installed_yq_version is less than $required_yq_version"
    exit 1
fi

echo "yq version $installed_yq_version is compatible, required version is $required_yq_version"

old_file=$overrideFile
echo -e "\nInput File Name: $old_file"

filename=$(basename "$old_file")
extension="${filename##*.}"                 # Get the extension
filename_without_extension="${filename%.*}" # Remove the extension
new_extension="migrated"
new_file_name="${filename_without_extension}-${new_extension}.${extension}"
echo -e "Migrated File Name: $new_file_name\n"

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
    echo "$old_content" >"$newOverrideFile"
    echo "Content copied from $old_file to $new_file_name in $dir_path"
  else
    echo "Invalid directory path: $dir_path"
    exit 1
  fi
else
  echo "$old_file does not exist."
  exit 1
fi

###################################################
#################### Migration ####################
###################################################

# What Changed?
# Harness components have been restructured for better packaging and modularization.

echo -e "\nMigrating $newOverrideFile"
echo

## platform
echo -e "\n----------------------------------------\n platform \n----------------------------------------"
# - Move ti-service from platform.ti-service.* to ci.ti-service.*
yq eval '(select(has("platform") and .platform | has("ti-service")) | .ci.ti-service = .platform.ti-service | del(.platform.ti-service)) // .' -i "$newOverrideFile"
echo "Migrated platform.ti-service to ci.ti-service"

# - New chart directory for srm
# - Move cv-nextgen, verification, learning-engine, le-nextgen from platform.* to srm.*
yq eval '(select(has("platform") and .platform | has("cv-nextgen")) | .srm.cv-nextgen = .platform.cv-nextgen | del(.platform.cv-nextgen)) // .' -i "$newOverrideFile"
echo "Migrated platform.cv-nextgen to srm.cv-nextgen "
yq eval '(select(has("platform") and .platform | has("verification-svc")) | .srm.verification-svc = .platform.verification-svc | del(.platform.verification-svc)) // .' -i "$newOverrideFile"
echo "Migrated platform.verification-svc to srm.verification-svc "
yq eval '(select(has("platform") and .platform | has("le-nextgen")) | .srm.le-nextgen = .platform.le-nextgen | del(.platform.le-nextgen)) // .' -i "$newOverrideFile"
echo "Migrated platform.le-nextgen to srm.le-nextgen "
yq eval '(select(has("platform") and .platform | has("learning-engine")) | .srm.learning-engine = .platform.learning-engine | del(.platform.learning-engine)) // .' -i "$newOverrideFile"
echo "Migrated platform.learning-engine to srm.learning-engine "

# - Move secrets from platform.harness-secrets to platform.bootstrap.harness-secrets
yq eval '(select(has("platform") and .platform | has("harness-secrets")) | .platform.bootstrap.harness-secrets = .platform.harness-secrets | del(.platform.harness-secrets)) // .' -i "$newOverrideFile"
echo "Migrated platform.harness-secrets to platform.bootstrap.harness-secrets "

# - minio moved from platform.minio to platform.boostrap.database.minio
yq eval '(select(has("platform") and .platform | has("minio")) | .platform.bootstrap.database.minio = .platform.minio | del(.platform.minio)) // .' -i "$newOverrideFile"
echo "Migrated platform.minio to platform.bootstrap.database.minio "

# - mongo moved from platform.mongo to platform.boostrap.database.mongo
yq eval '(select(has("platform") and .platform | has("mongodb")) | .platform.bootstrap.database.mongodb = .platform.mongodb | del(.platform.mongodb)) // .' -i "$newOverrideFile"
echo "Migrated platform.mongodb to platform.bootstrap.database.mongodb "

# - redis moved from platform.redis to platform.boostrap.database.redis
yq eval '(select(has("platform") and .platform | has("redis")) | .platform.bootstrap.database.redis = .platform.redis | del(.platform.redis)) // .' -i "$newOverrideFile"
echo "Migrated platform.redis to platform.bootstrap.database.redis "

# - timescaledb moved from platform.timescaledb to platform.boostrap.database.timescaledb
yq eval '(select(has("platform") and .platform | has("timescaledb")) | .platform.bootstrap.database.timescaledb = .platform.timescaledb | del(.platform.timescaledb)) // .' -i "$newOverrideFile"
echo "Migrated platform.timescaledb to platform.bootstrap.database.timescaledb "
echo

## infra
echo -e "\n----------------------------------------\n infra \n----------------------------------------"
# - postgresql moved from infra.postgresql to platform.boostrap.database.postgresql
yq eval '(select(has("infra") and .infra | has("postgresql")) | .platform.bootstrap.database.postgresql = .infra.postgresql | del(.infra)) // .' -i "$newOverrideFile"
echo "Migrated infra.postgresql to platform.bootstrap.database.postgresql "
echo

## gitops
echo -e "\n----------------------------------------\n gitops \n----------------------------------------"
# - created a seperate chart "cd" to consists gitops.
# - move gitops.* to cd.gitops.*
yq eval '(select(has("gitops")) | .cd.gitops = .gitops | del(.gitops)) // .' -i "$newOverrideFile"
echo "Migrated gitops to cd.gitops "
echo

## ccm
echo -e "\n----------------------------------------\n ccm \n----------------------------------------"
# - clickhouse moved from ccm.clickhouse to platform.boostrap.database.clickhouse
yq eval '(select(has("ccm") and .ccm | has("clickhouse")) | .platform.bootstrap.database.clickhouse = .ccm.clickhouse ) // .' -i "$newOverrideFile"
echo "Migrated ccm.clickhouse to platform.bootstrap.database.clickhouse "

# - clickhouse enabled moved to global flag. earlier ccm.clickhouse.enabled converted to global.database.clickhouse.enabled
yq eval '(select(has("ccm") and .ccm | has("clickhouse")) | .global.database.clickhouse = .ccm.clickhouse | del(.ccm.clickhouse)) // (select(.global.database.clickhouse == null) | .global.database.clickhouse += {"enabled": false}) // .' -i "$newOverrideFile"
yq eval 'del(.ccm.nextgen-ce.clickhouse)' -i "$newOverrideFile"
yq eval 'del(.ccm.batch-processing.clickhouse)' -i "$newOverrideFile"
echo "Migrated ccm.clickhouse to global.database.clickhouse "

# - Rename nextgen-ce to ce-nextgen
yq eval '(select(has("ccm") and .ccm | has("nextgen-ce")) | .ccm.ce-nextgen = .ccm.nextgen-ce | del(.ccm.nextgen-ce)) // .' -i "$newOverrideFile"
echo "Migrated ccm.nextgen-ce to ccm.ce-nextgen"
echo

## ngcustomdashboard
echo -e "\n----------------------------------------\n ngcustomdashboard \n----------------------------------------"
# - moved ngcustomdashboard.* to platform.*
yq eval '(select(has("ngcustomdashboard") and .ngcustomdashboard | has("ng-custom-dashboards")) | .platform.ng-custom-dashboards = .ngcustomdashboard.ng-custom-dashboards) // .' -i "$newOverrideFile"
yq eval '(select(has("ngcustomdashboard") and .ngcustomdashboard | has("looker")) | .platform.looker = .ngcustomdashboard.looker | del(.ngcustomdashboard)) // .' -i "$newOverrideFile"
echo "Migrated ngcustomdashboard to platform"
yq eval '(select(.platform.looker.ingress.host != null and .platform.looker.ingress.hosts ==null ) | .platform.looker.ingress.hosts = [] ) // . | del(.platform.looker.ingress.host) ' -i "$newOverrideFile"
echo "moved looker.ingress.host to looker.ingress.hosts"

## policy-mgmt
echo -e "\n----------------------------------------\n policy-mgmt \n----------------------------------------"
# - move policy-mgmt.* into platform.policy-mgmt.*
yq eval '(select(has("policy-mgmt")) | .platform.policy-mgmt = .policy-mgmt | del(.policy-mgmt)) // .' -i "$newOverrideFile"
echo "Migrated policy-mgmt to platform.policy-mgmt "
echo

#################### chaos ####################
yq eval 'del(.chaos.chaos-driver)' -i "$newOverrideFile"

#################### ff ####################
# - no changes

#################### sto ####################
# - no changes

## global
echo -e "\n----------------------------------------\n global \n----------------------------------------"
# - move rbac/service-account from platform.harness-manager to platform.bootstrap.rbac
echo "No change required for bootstrap/rbac chart "

# - move global.ingress.nginx to platform.bootstrap.networking.nginx
yq eval '(select(.global.ingress.nginx.objects != null) | .global.ingress.objects = .global.ingress.nginx.objects | del(.global.ingress.nginx.objects)) // .' -i "$newOverrideFile"
echo "Migrated global.ingress.nginx.objects to global.ingress.objects "

yq eval '(select( .global | has("ingress") and .global.ingress | has("nginx")) | .platform.bootstrap.networking.nginx = .global.ingress.nginx | del(.global.ingress.nginx)) // .' -i "$newOverrideFile"
echo "Migrated global.ingress.nginx to platform.bootstrap.networking.nginx "
# - move global.ingress.loadBalancerEnabled to platform.bootstrap.networking.nginx.loadBalancerEnabled
yq eval '(select( .global | has("ingress") and .global.ingress | has("loadBalancerEnabled")) | .platform.bootstrap.networking.nginx.loadBalancerEnabled = .global.ingress.loadBalancerEnabled | del(.global.ingress.loadBalancerEnabled)) // .' -i "$newOverrideFile"
# - move global.ingress.loadBalancerIP to platform.bootstrap.networking.nginx.loadBalancerIP
yq eval '(select( .global | has("ingress") and .global.ingress | has("loadBalancerIP")) | .platform.bootstrap.networking.nginx.loadBalancerIP = .global.ingress.loadBalancerIP | del(.global.ingress.loadBalancerIP)) // .' -i "$newOverrideFile"
echo "Migrated global.ingress.loadBalancer* to platform.bootstrap.networking.nginx.loadBalancer* "


# - move global.ingress.nginx to platform.bootstrap.networking.nginx
yq eval '(select( .global | has("ingress") and .global.ingress | has("defaultbackend")) | .platform.bootstrap.networking.defaultbackend = .global.ingress.defaultbackend | del(.global.ingress.defaultbackend)) // .' -i "$newOverrideFile"
echo "Migrated global.ingress.defaultbackend to platform.bootstrap.networking.defaultbackend "

#
yq eval 'del(.ng-manager)' -i "$newOverrideFile"
echo "Set lwd and ccm to defaultly false "

yq eval '.global.lwd.autocud.enabled = false | .global.lwd.enabled = false' -i "$newOverrideFile"

###################################################

yq eval -i 'sortKeys(..)' $newOverrideFile

# - keep global at the top
yq eval '. as $doc | del(.global) | {"global": $doc.global} + $doc ' -i  $newOverrideFile

echo -e "\nMigration completed\n"
