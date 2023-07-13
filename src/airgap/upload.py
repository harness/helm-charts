import argparse
import os
import subprocess

def upload_to_bucket(service_account_file, source_file_name, destination_bucket_path):
    # Set the environment variable for the service account
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = service_account_file
    
    # Construct the gsutil cp command
    gsutil_command = ["gsutil", "cp", source_file_name, destination_bucket_path]
    
    # Execute the command using subprocess
    try:
        subprocess.run(gsutil_command, check=True)
        print(f"File {source_file_name} uploaded to {destination_bucket_path}.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while uploading the file: {str(e)}")

if __name__ == "__main__":
    # Define the bucket path
    bucket_path = "gs://smp-airgap-bundles"
    
    parser = argparse.ArgumentParser(description="Upload a file to Google Cloud Storage bucket using gsutil.")
    parser.add_argument("service_account_file", help="Path to the service account JSON file.")
    parser.add_argument("source_file", help="Path to the file to be uploaded.")
    args = parser.parse_args()
    
    # Construct the destination bucket path using the defined bucket path
    destination_bucket_path = f"{bucket_path}/{args.source_file.split('/')[-1]}"

    upload_to_bucket(args.service_account_file, args.source_file, destination_bucket_path)
