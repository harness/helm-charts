## Airgap bundle creation process

**airgap_input.txt** 

This file contains list of module specific images which are validated by module team. This file is used to create module specific .tgz image bundle


**create_airgap_module_images.sh**

This script needs 2 inputs, images.txt and airgap_input.txt, It creates module specific image file list in txt file. This will create separate image list file for each module.

**create-airgap-bundle.sh**

This script uses image list files created by create_airgap_module_images.sh script and pulls the images from docker registry and saves it in respective .tgz file (example: it uses platform_images.txt and creates platform_images.tgz)

**upload_bundles.sh**
This file uses upload.py script and google service account file for authentication and accepts user input as release number (e.g. harness-x.x.x)

It uploads all image bundles to harness-x.x.x folder in google bucket gs://smp-airgap-bundles

**harness-airgap-images.sh**

This file takes an airgap bundle, tags images and pushes it into private registry.
