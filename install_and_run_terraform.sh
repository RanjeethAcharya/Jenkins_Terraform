#!/bin/bash
set -e

# Script to install Terraform locally (no sudo required)
# Installs version 1.14.3

TERRAFORM_VERSION="1.14.3"

echo "Detecting architecture..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    TF_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    TF_ARCH="arm64"
else
    echo "Unix architecture $ARCH not explicitly supported by this script (assuming amd64)."
    TF_ARCH="amd64"
fi

echo "Detected architecture: $TF_ARCH"

echo "Downloading Terraform v${TERRAFORM_VERSION}..."
curl -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"

echo "Unzipping Terraform..."
if command -v unzip >/dev/null 2>&1; then
    unzip -o "terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"
elif command -v python3 >/dev/null 2>&1; then
    echo "unzip not found, using python3..."
    python3 -c "import zipfile; import sys; zipfile.ZipFile(sys.argv[1]).extractall('.')" "terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"
elif command -v python >/dev/null 2>&1; then
    echo "unzip not found, using python..."
    python -c "import zipfile; import sys; zipfile.ZipFile(sys.argv[1]).extractall('.')" "terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"
else
    echo "Error: Neither 'unzip', 'python3', nor 'python' found. Cannot extract Terraform."
    exit 1
fi

echo "Cleaning up zip file..."
rm "terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"

echo "Making terraform executable..."
chmod +x terraform

echo "Terraform installation complete. Local version:"
./terraform --version
