"""
This script pulls Docker images based on the provided modules and images file.
Usage: python script.py images_file module1 [module2 ...]
Example: python airgap_for_modules.py images.txt CD-CG FF (This will download the unique containers required for CD-CG and FF)

How to obtain images.txt:
    - Go to https://github.com/harness/helm-charts/releases

    - Select the release you want to create airgap bundle for and copy the docker container list in images.txt and save it in local directory

Arguments:
images_file: A text file containing Docker images (one image per line).
module1, module2, ...: One or more module names. Modules correspond to sets of Docker images.
"""

import sys
import os
import subprocess
import re
from collections import defaultdict


# Define dictionary to hold the module-container mappings
module_containers = defaultdict(list)

# Container mappings
module_containers = {
    "CD-CG": ["default-backend", "delegate-proxy", "delegate:", "event-service", "gateway", "/manager-signed", "/ui-signed", "mongodb", "timescaledb", "verification"],
    "CD-NG": ["accesscontrol-service", "cv-nextgen", "default-backend", "delegate-proxy", "delegate:", "event-service", "gateway", "gitops-service", "/manager-signed", "log-service", "mongodb", "nextgenui", "ng-manager", "pipeline-service", "platform-service", "policy-mgmt", "redis", "scm", "template-service", "timescaledb"],
    "CI": ["accesscontrol-service", "ci-manager", "default-backend", "delegate-proxy", "delegate:", "event-service", "gateway", "harness-ingress-controller", "/manager-signed", "/ui-signed", "log-service", "mongodb", "nextgenui", "ng-manager", "pipeline-service", "platform-service", "policy-mgmt", "redis", "scm", "template-service", "ti-service", "timescaledb"],
    "CCM": ["accesscontrol-service", "batch-processing", "ce-nextgen", "cloud-info", "delegate:", "event-service", "gateway", "harness-ingress-controller", "/manager-signed", "/ui-signed", "mongodb", "nextgenui", "ng-manager", "policy-mgmt", "redis", "telescopes", "timescaledb", "Lightwing API service", "Lightwing BG worker"],
    "FF": ["accesscontrol-service", "gateway", "nextgenui", "ng-manager", "pipeline-service", "policy-mgmt", "redis", "scm", "timescaledb", "ff-admin-server-svc"],
    "SRM": ["accesscontrol-service", "cv-nextgen", "default-backend", "delegate:", "gateway", "harness-ingress-controller", "/manager-signed", "mongodb", "nextgenui", "ng-manager", "pipeline-service", "platform-service", "policy-mgmt"],
    "STO": ["accesscontrol-service", "ci-manager", "delegate-proxy", "delegate:", "event-service", "gateway", "harness-ingress-controller", "/ui-signed", "nextgenui", "ng-manager", "pipeline-service", "policy-mgmt", "redis", "sto-manager", "stocore", "template-service", "ti-service"],
    "Chaos": ["accesscontrol-service", "delegate:", "gateway", "harness-ingress-controller", "log-service", "mongodb", "nextgenui", "ng-manager", "platform-service", "redis"]
}

# Check if the first argument is -h or --help
if sys.argv[1] in ["-h", "--help"]:
    print("Usage: script.py [IMAGES_FILE] [MODULE]...")
    print("Download the unique container images required by the given MODULEs.")
    print("Arguments:")
    print("  IMAGES_FILE    A file containing the list of container images.")
    print("  MODULE         A module for which to download container images.")
    print("                 Can be one or more of: CD-CG CD-NG CI CCM FF SRM STO Chaos")
    print("Options:")
    print("  -h, --help     Display this help and exit")
    sys.exit(0)

# If not enough arguments are provided, print help and exit with error
if len(sys.argv) < 3:
    print("Error: You must provide an images file and at least one module name")
    sys.exit(1)

# Take the images file as the first command-line argument
images_file = sys.argv[1]
input_modules = sys.argv[2:]

unique_containers = set()

# Iterate over the input modules
for module in input_modules:
    # Check if the module name is recognized
    if module not in module_containers:
        print("Error: Unrecognized module name: ", module)
        sys.exit(1)

    # Get the containers for this module and add them to the set of unique containers
    unique_containers.update(module_containers[module])

print("Here is a list of unique containers", unique_containers)

os.makedirs("airgap_bundle", exist_ok=True)

downloaded_images = 0
found_containers = set()

# Read the images file line by line
with open(images_file, 'r') as f:
    for line in f:
        # Check if the line contains any of the unique containers
        for container in unique_containers:
            if re.search(rf'\b{re.escape(container)}\b', line):
                print(f"Downloading {line.strip()}...")
                subprocess.run(["docker", "pull", line.strip()])
                subprocess.run(["docker", "save", line.strip(), "-o", f"airgap_bundle/{line.strip().replace('/', '_').replace(':', '_')}.tar"])
                downloaded_images += 1
                found_containers.add(container)
                break

# Find any unique containers that were not found in images.txt
not_found_containers = unique_containers - found_containers

if not_found_containers:
    print("The following containers were not found in images.txt:")
    for container in not_found_containers:
        print(f"  {container}")

# Create tar.gz file
subprocess.run(["tar", "-czf", "airgap_bundle.tar.gz", "airgap_bundle"])

print(f"Total downloaded images: {downloaded_images}")