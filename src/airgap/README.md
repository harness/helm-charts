**How to create Airgap bundle and upload it to GCP bucket**


**Run create_module_lists.sh**

This script needs 2 inputs, images.txt and airgap_input.txt, It creates module specific image file list in txt file. This will create separate image list file for each module.

**Usage**
create_module_lists.sh src/harness/images.txt airgap_input.txt

*airgap_input.txt* 

This file contains list of module specific images which are validated by module team. This file is used to create module specific .tgz image bundle

**create-airgap-bundle.sh**

This script uses image list files created by create_module_lists.sh script and pulls the images from docker registry and saves it in respective .tgz file (example: it uses platform_images.txt and creates platform_images.tgz)

**Usage:**

create-airgap-bundle.sh

**upload_all_bundles.sh**
This file uses google service account file and accepts release number as input and creates directory in bucket with release name and upload all bundles in that directory in google bucket gs://smp-airgap-bundles

**Usage:**

upload_all_bundles.sh service_account_key.json harness-x.x.x

**harness-airgap-images.sh**
This file takes an airgap bundle, tags images and pushes it into private registry.